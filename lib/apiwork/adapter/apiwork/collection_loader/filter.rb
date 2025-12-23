# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class Filter
          EQUALITY_OPERATORS = %i[eq].freeze
          COMPARISON_OPERATORS = %i[gt gte lt lte].freeze
          RANGE_OPERATORS = %i[between].freeze
          COLLECTION_OPERATORS = %i[in].freeze
          STRING_SPECIFIC_OPERATORS = %i[contains starts_with ends_with].freeze
          NULL_OPERATORS = %i[null].freeze

          STRING_OPERATORS = (EQUALITY_OPERATORS + COLLECTION_OPERATORS + STRING_SPECIFIC_OPERATORS).freeze
          DATE_OPERATORS = (EQUALITY_OPERATORS + COMPARISON_OPERATORS + RANGE_OPERATORS + COLLECTION_OPERATORS).freeze
          NUMERIC_OPERATORS = (EQUALITY_OPERATORS + COMPARISON_OPERATORS + RANGE_OPERATORS + COLLECTION_OPERATORS).freeze
          UUID_OPERATORS = (EQUALITY_OPERATORS + COLLECTION_OPERATORS).freeze
          BOOLEAN_OPERATORS = EQUALITY_OPERATORS.freeze

          NULLABLE_STRING_OPERATORS = (STRING_OPERATORS + NULL_OPERATORS).freeze
          NULLABLE_DATE_OPERATORS = (DATE_OPERATORS + NULL_OPERATORS).freeze
          NULLABLE_NUMERIC_OPERATORS = (NUMERIC_OPERATORS + NULL_OPERATORS).freeze
          NULLABLE_UUID_OPERATORS = (UUID_OPERATORS + NULL_OPERATORS).freeze
          NULLABLE_BOOLEAN_OPERATORS = (BOOLEAN_OPERATORS + NULL_OPERATORS).freeze

          LOGICAL_OPERATORS = %i[_and _or _not].freeze

          attr_reader :schema_class

          def self.filter(relation, schema_class, filter_params, issues)
            new(relation, schema_class, issues).filter(filter_params)
          end

          def initialize(relation, schema_class, issues)
            @relation = relation
            @schema_class = schema_class
            @issues = issues
          end

          def filter(params)
            return @relation if params.blank?

            case params
            when Hash
              apply_hash_filter(params)
            when Array
              apply_array_filter(params)
            end
          end

          private

          def apply_hash_filter(params)
            logical_ops, regular_attrs = separate_logical_operators(params)

            scope = @relation

            if regular_attrs.present?
              conditions, joins = build_where_conditions(regular_attrs, schema_class.model_class)
              scope = with_joins_and_distinct(scope, joins) { |s| s.where(conditions.reduce(:and)) } if conditions.any?
            end

            scope = apply_not(scope, logical_ops[:_not]) if logical_ops.key?(:_not)
            scope = apply_or(scope, logical_ops[:_or]) if logical_ops.key?(:_or)
            scope = apply_and(scope, logical_ops[:_and]) if logical_ops.key?(:_and)

            scope
          end

          def apply_array_filter(params)
            return @relation if params.empty?

            individual_conditions = params.map do |filter_hash|
              conditions, _joins = build_where_conditions(filter_hash, schema_class.model_class)
              conditions.compact.reduce(:and) if conditions.any?
            end.compact

            or_condition = individual_conditions.reduce(:or) if individual_conditions.any?
            all_joins = params.map { |p| build_where_conditions(p, schema_class.model_class)[1] }.reduce({}) { |acc, j| acc.deep_merge(j) }

            with_joins_and_distinct(@relation, all_joins) do |scope|
              or_condition ? scope.where(or_condition) : scope
            end
          end

          def apply_not(scope, filter_params)
            condition, joins = build_conditions_recursive(filter_params)
            return scope if condition.nil?

            with_joins_and_distinct(scope, joins) { |s| s.where.not(condition) }
          end

          def apply_or(scope, conditions_array)
            return scope if conditions_array.blank?

            or_conditions = []
            all_joins = {}

            conditions_array.each do |filter_hash|
              conditions, joins = build_conditions_recursive(filter_hash)
              or_conditions << conditions if conditions
              all_joins = all_joins.deep_merge(joins)
            end

            or_condition = or_conditions.compact.reduce(:or) if or_conditions.any?

            with_joins_and_distinct(scope, all_joins) do |s|
              or_condition ? s.where(or_condition) : s
            end
          end

          def apply_and(scope, conditions_array)
            return scope if conditions_array.blank?

            conditions_array.reduce(scope) do |current_scope, filter_hash|
              Filter.filter(current_scope, schema_class, filter_hash, @issues)
            end
          end

          def build_conditions_recursive(filter_params)
            return [nil, {}] if filter_params.blank?
            return [nil, {}] unless filter_params.is_a?(Hash)

            logical_ops, regular_attrs = separate_logical_operators(filter_params)

            conditions = []
            all_joins = {}

            if regular_attrs.present?
              attribute_conditions, joins = build_where_conditions(regular_attrs, schema_class.model_class)
              conditions << attribute_conditions.reduce(:and) if attribute_conditions.any?
              all_joins = all_joins.deep_merge(joins)
            end

            if logical_ops.key?(:_and)
              cond, joins = process_logical_operator(logical_ops[:_and], :and)
              conditions << cond if cond
              all_joins = all_joins.deep_merge(joins)
            end

            if logical_ops.key?(:_or)
              cond, joins = process_logical_operator(logical_ops[:_or], :or)
              conditions << cond if cond
              all_joins = all_joins.deep_merge(joins)
            end

            if logical_ops.key?(:_not)
              not_cond, joins = build_conditions_recursive(logical_ops[:_not])
              conditions << not_cond.not if not_cond
              all_joins = all_joins.deep_merge(joins)
            end

            final_condition = conditions.compact.reduce(:and)
            [final_condition, all_joins]
          end

          def process_logical_operator(filters, combinator)
            collected_conditions = []
            all_joins = {}

            filters.each do |filter_hash|
              cond, joins = build_conditions_recursive(filter_hash)
              collected_conditions << cond if cond
              all_joins = all_joins.deep_merge(joins)
            end

            combined = collected_conditions.reduce(combinator) if collected_conditions.any?
            [combined, all_joins]
          end

          def build_where_conditions(filter, target_klass = schema_class.model_class)
            filter.each_with_object([[], {}]) do |(key, value), (conditions, joins)|
              key = key.to_sym

              if (attribute_definition = schema_class.attribute_definitions[key])&.filterable?
                next unless filterable_for_context?(attribute_definition)

                condition_result = build_column_condition(key, value, target_klass)
                conditions << condition_result if condition_result

              elsif (association = find_filterable_association(key))
                association_conditions, association_joins = build_join_conditions(key, value, association)
                conditions.concat(association_conditions)
                joins.deep_merge!(association_joins)

              else
                collect_filterable_error(key, target_klass)
              end
            end
          end

          def filterable_for_context?(attribute_definition)
            filterable = attribute_definition.filterable?
            return true unless filterable.is_a?(Proc)

            schema_class.new(nil, {}).instance_eval(&filterable)
          end

          def collect_filterable_error(key, target_klass)
            available = schema_class.attribute_definitions
                                    .select { |_, definition| definition.filterable? }
                                    .keys

            @issues << Issue.new(
              layer: :contract,
              code: :field_not_filterable,
              detail: "#{key} is not a filterable attribute on #{target_klass.name}. Available: #{available.join(', ')}",
              path: [:filter, key],
              meta: { field: key, class: target_klass.name, available: available }
            )
          end

          def build_column_condition(key, value, target_klass)
            validate_enum_values!(key, value, target_klass) if target_klass.defined_enums.key?(key.to_s)

            column_type = target_klass.type_for_attribute(key).type
            if column_type.nil?
              @issues << Issue.new(
                layer: :contract,
                code: :unknown_column_type,
                detail: "Cannot determine type for attribute '#{key}' on #{target_klass.name}",
                path: [key.to_s],
                meta: { field: key.to_s }
              )
              return nil
            end

            case column_type
            when :uuid
              build_uuid_where_clause(key, value, target_klass)
            when :string, :text
              build_string_where_clause(key, value, target_klass)
            when :date, :datetime
              build_date_where_clause(key, value, target_klass)
            when :decimal, :integer, :float
              build_numeric_where_clause(key, value, target_klass)
            when :boolean
              build_boolean_where_clause(key, value, target_klass)
            else
              @issues << Issue.new(
                layer: :contract,
                code: :unsupported_column_type,
                detail: "Unsupported column type: #{column_type}",
                path: [:filter, key],
                meta: { field: key, type: column_type }
              )
              nil
            end
          end

          def validate_enum_values!(key, value, target_klass)
            enum_values = target_klass.defined_enums[key.to_s].keys
            invalid_values = extract_values_from_filter(value) - enum_values

            return if invalid_values.empty?

            @issues << Issue.new(
              layer: :contract,
              code: :invalid_enum_value,
              detail: "Invalid #{key} value(s): #{invalid_values.join(', ')}. Valid values: #{enum_values.join(', ')}",
              path: [:filter, key],
              meta: { field: key, invalid: invalid_values, valid: enum_values }
            )
          end

          def extract_values_from_filter(value)
            case value
            when String
              [value]
            when Array
              value
            when Hash
              value.values.flatten.compact
            else
              []
            end
          end

          def find_filterable_association(key)
            association = schema_class.association_definitions[key]
            return unless association
            return unless association.filterable?

            association
          end

          def build_join_conditions(key, value, association)
            reflection = schema_class.model_class.reflect_on_association(key)
            association_resource = association.schema_class || infer_association_schema(reflection)

            unless association_resource
              @issues << Issue.new(
                layer: :contract,
                code: :association_resource_not_found,
                detail: "Cannot find resource for association #{key}",
                path: [:filter, key],
                meta: { association: key }
              )
              return [[], {}]
            end

            association_reflection = schema_class.model_class.reflect_on_association(key)
            unless association_reflection
              @issues << Issue.new(
                layer: :contract,
                code: :association_not_found,
                detail: "Association #{key} not found on #{schema_class.model_class.name}",
                path: [:filter, key],
                meta: { association: key, class: schema_class.model_class.name }
              )
              return [[], {}]
            end

            nested_query = Filter.new(association_reflection.klass.all, association_resource, @issues)
            nested_conditions, nested_joins = nested_query.send(:build_where_conditions, value, association_reflection.klass)

            [nested_conditions, { key => (nested_joins.any? ? nested_joins : {}) }]
          end

          def build_uuid_where_clause(key, value, target_klass)
            column = target_klass.arel_table[key]

            normalizer = lambda do |val|
              case val
              when String
                val.include?(',') ? { in: val.split(',') } : { eq: val }
              when Array
                { in: val }
              else
                val
              end
            end

            builder = Builder.new(
              column: column,
              field_name: key,
              issues: @issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: NULLABLE_UUID_OPERATORS, normalizer: normalizer) do |operator, compare|
              case operator
              when :eq then column.eq(compare)
              when :in then column.in(compare)
              when :null then handle_null_operator(column, compare)
              end
            end
          end

          def build_string_where_clause(key, value, target_klass)
            column = target_klass.arel_table[key]

            normalizer = ->(val) { val.is_a?(String) || val.nil? ? { eq: val } : val }

            builder = Builder.new(
              column: column,
              field_name: key,
              issues: @issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: NULLABLE_STRING_OPERATORS,
                                 normalizer: normalizer) do |operator, compare|
              case operator
              when :eq then column.eq(compare)
              when :contains then case_sensitive_pattern_match(column, "%#{compare}%")
              when :starts_with then case_sensitive_pattern_match(column, "#{compare}%")
              when :ends_with then case_sensitive_pattern_match(column, "%#{compare}")
              when :in then column.in(compare)
              when :null then handle_null_operator(column, compare)
              end
            end
          end

          def build_date_where_clause(key, value, target_klass)
            column = target_klass.arel_table[key]
            column_metadata = target_klass.columns_hash[key.to_s]
            allow_nil = column_metadata&.null != false

            if value.is_a?(String) || value.nil?
              return handle_date_nil_value(column, key, allow_nil) if value.blank?

              return column.eq(parse_date(value, key))
            end

            normalizer = ->(val) { val }

            builder = Builder.new(
              column: column,
              field_name: key,
              issues: @issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: NULLABLE_DATE_OPERATORS, normalizer: normalizer) do |operator, compare|
              if operator == :null
                handle_null_operator(column, compare)
              elsif compare.blank?
                handle_date_nil_value(column, key, allow_nil)
              elsif operator == :between && compare.is_a?(Hash)
                from_date = parse_date(compare[:from] || compare['from'], key)
                to_date = parse_date(compare[:to] || compare['to'], key)
                next unless from_date && to_date

                column.gteq(from_date.beginning_of_day).and(column.lteq(to_date.end_of_day))
              else
                date = parse_date(compare, key)
                case operator
                when :eq then column.eq(date)
                when :gt then column.gt(date)
                when :gte then column.gteq(date)
                when :lt then column.lt(date)
                when :lte then column.lteq(date)
                when :in then column.in(Array(date))
                end
              end
            end
          end

          def handle_date_nil_value(column, key, allow_nil)
            unless allow_nil
              @issues << Issue.new(
                layer: :contract,
                code: :null_not_allowed,
                detail: "#{key} cannot be null",
                path: [:filter, key],
                meta: { field: key }
              )
            end

            column.eq(nil)
          end

          def build_numeric_where_clause(key, value, target_klass)
            column = target_klass.arel_table[key]

            normalizer = ->(val) { [String, Numeric, NilClass].any? { |t| val.is_a?(t) } ? { eq: val } : val }

            builder = Builder.new(
              column: column,
              field_name: key,
              issues: @issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: NULLABLE_NUMERIC_OPERATORS,
                                 normalizer: normalizer) do |operator, compare|
              case operator
              when :eq
                number = parse_numeric(compare, key)
                column.eq(number)
              when :gt
                number = parse_numeric(compare, key)
                column.gt(number)
              when :gte
                number = parse_numeric(compare, key)
                column.gteq(number)
              when :lt
                number = parse_numeric(compare, key)
                column.lt(number)
              when :lte
                number = parse_numeric(compare, key)
                column.lteq(number)
              when :between
                if compare.is_a?(Hash)
                  from_number = parse_numeric(compare[:from] || compare['from'], key)
                  to_number = parse_numeric(compare[:to] || compare['to'], key)
                  next unless from_number && to_number

                  column.between(from_number..to_number)
                else
                  number = parse_numeric(compare, key)
                  next unless number

                  column.between(number..number)
                end
              when :in
                numbers = Array(compare).filter_map { |v| parse_numeric(v, key) }
                next if numbers.empty?

                column.in(numbers)
              when :null
                handle_null_operator(column, compare)
              end
            end
          end

          def build_boolean_where_clause(key, value, target_klass)
            column = target_klass.arel_table[key]

            normalizer = lambda do |val|
              if [true, false, nil].include?(val) || ['true', 'false', '1', '0', 1, 0].include?(val)
                { eq: normalize_boolean(val) }
              else
                val
              end
            end

            builder = Builder.new(
              column: column,
              field_name: key,
              issues: @issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: NULLABLE_BOOLEAN_OPERATORS,
                                 normalizer: normalizer) do |operator, compare|
              case operator
              when :eq
                bool_value = normalize_boolean(compare)
                column.eq(bool_value)
              when :null
                handle_null_operator(column, compare)
              end
            end
          end

          def handle_null_operator(column, compare)
            if [true, 'true', 1, '1'].include?(compare)
              column.eq(nil)
            else
              column.not_eq(nil)
            end
          end

          def normalize_boolean(value)
            return nil if value.nil?

            [true, 'true', 1, '1'].include?(value)
          end

          def parse_date(value, field)
            DateTime.parse(value.to_s)
          rescue ArgumentError
            @issues << Issue.new(
              layer: :contract,
              code: :invalid_date_format,
              detail: "'#{value}' is not a valid date",
              path: [:filter, field],
              meta: { field: field, value: value }
            )
            nil
          end

          def parse_numeric(value, field)
            case value
            when Numeric then value
            when String then Float(value)
            else
              @issues << Issue.new(
                layer: :contract,
                code: :invalid_numeric_format,
                detail: "'#{value}' is not a valid number",
                path: [:filter, field],
                meta: { field: field, value: value }
              )
              nil
            end
          rescue ArgumentError
            @issues << Issue.new(
              layer: :contract,
              code: :invalid_numeric_format,
              detail: "'#{value}' is not a valid number",
              path: [:filter, field],
              meta: { field: field, value: value }
            )
            nil
          end

          def sqlite_adapter?
            @sqlite_adapter ||= schema_class.model_class.connection.adapter_name == 'SQLite'
          end

          def case_sensitive_pattern_match(column, pattern)
            if sqlite_adapter?
              glob_pattern = pattern.tr('%', '*')
              Arel::Nodes::InfixOperation.new('GLOB', column, Arel::Nodes.build_quoted(glob_pattern))
            else
              column.matches(pattern)
            end
          end

          def separate_logical_operators(params)
            [params.slice(*LOGICAL_OPERATORS), params.except(*LOGICAL_OPERATORS)]
          end

          def with_joins_and_distinct(scope, joins)
            result = yield(joins.present? ? scope.joins(joins) : scope)
            joins.present? ? result.distinct : result
          end

          def infer_association_schema(reflection)
            return nil if reflection.polymorphic?

            namespace = schema_class.name.deconstantize
            "#{namespace}::#{reflection.klass.name}Schema".safe_constantize
          end
        end
      end
    end
  end
end
