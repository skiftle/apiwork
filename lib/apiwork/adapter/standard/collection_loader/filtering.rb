# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard < Base
      class CollectionLoader
        module Filtering
          include Apiwork::Schema::Operator

          def apply_filter(scope, params, issues = [])
            return scope if params.blank?

            case params
            when Hash
              logical_ops = params.slice(:_and, :_or, :_not)
              regular_attrs = params.except(:_and, :_or, :_not)

              if regular_attrs.present?
                conditions, joins = build_where_conditions(regular_attrs, schema_class.model_class, issues)
                result = scope.joins(joins).where(conditions.reduce(:and))
                scope = joins.present? ? result.distinct : result
              end

              scope = apply_not(scope, logical_ops[:_not], issues) if logical_ops.key?(:_not)
              scope = apply_or(scope, logical_ops[:_or], issues) if logical_ops.key?(:_or)
              scope = apply_and(scope, logical_ops[:_and], issues) if logical_ops.key?(:_and)

              scope
            when Array
              individual_conditions = params.map do |filter_hash|
                conditions, _joins = build_where_conditions(filter_hash, schema_class.model_class, issues)
                conditions.compact.reduce(:and) if conditions.any?
              end.compact

              or_condition = individual_conditions.reduce(:or) if individual_conditions.any?
              all_joins = params.map { |p| build_where_conditions(p, schema_class.model_class, issues)[1] }.reduce({}) { |acc, j| acc.deep_merge(j) }

              result = scope
              result = result.joins(all_joins) if all_joins.present?
              result = result.where(or_condition) if or_condition
              all_joins.present? ? result.distinct : result
            end
          end

          private

          def apply_not(scope, filter_params, issues = [])
            condition, joins = build_conditions_recursive(filter_params, issues)

            return scope if condition.nil?

            result = scope.joins(joins)
            result = result.where.not(condition)
            joins.present? ? result.distinct : result
          end

          def apply_or(scope, conditions_array, issues = [])
            return scope if conditions_array.blank?

            or_conditions = []
            all_joins = {}

            conditions_array.each do |filter_hash|
              conditions, joins = build_conditions_recursive(filter_hash, issues)
              or_conditions << conditions if conditions
              all_joins = all_joins.deep_merge(joins)
            end

            or_condition = or_conditions.compact.reduce(:or) if or_conditions.any?

            result = scope
            result = result.joins(all_joins) if all_joins.present?
            result = result.where(or_condition) if or_condition
            all_joins.present? ? result.distinct : result
          end

          def apply_and(scope, conditions_array, issues = [])
            return scope if conditions_array.blank?

            conditions_array.reduce(scope) do |current_scope, filter_hash|
              apply_filter(current_scope, filter_hash, issues)
            end
          end

          def build_conditions_recursive(filter_params, issues = [])
            return [nil, {}] if filter_params.blank?
            return [nil, {}] unless filter_params.is_a?(Hash)

            logical_ops = filter_params.slice(:_and, :_or, :_not)
            regular_attrs = filter_params.except(:_and, :_or, :_not)

            conditions = []
            all_joins = {}

            if regular_attrs.present?
              attr_conditions, joins = build_where_conditions(regular_attrs, schema_class.model_class, issues)
              conditions << attr_conditions.reduce(:and) if attr_conditions.any?
              all_joins = all_joins.deep_merge(joins)
            end

            if logical_ops.key?(:_and)
              cond, joins = process_logical_operator(logical_ops[:_and], :and, issues)
              conditions << cond if cond
              all_joins = all_joins.deep_merge(joins)
            end

            if logical_ops.key?(:_or)
              cond, joins = process_logical_operator(logical_ops[:_or], :or, issues)
              conditions << cond if cond
              all_joins = all_joins.deep_merge(joins)
            end

            if logical_ops.key?(:_not)
              not_cond, joins = build_conditions_recursive(logical_ops[:_not], issues)
              conditions << not_cond.not if not_cond
              all_joins = all_joins.deep_merge(joins)
            end

            final_condition = conditions.compact.reduce(:and)
            [final_condition, all_joins]
          end

          def process_logical_operator(filters, combinator, issues = [])
            collected_conditions = []
            all_joins = {}

            filters.each do |filter_hash|
              cond, joins = build_conditions_recursive(filter_hash, issues)
              collected_conditions << cond if cond
              all_joins = all_joins.deep_merge(joins)
            end

            combined = collected_conditions.reduce(combinator) if collected_conditions.any?
            [combined, all_joins]
          end

          def build_where_conditions(filter, target_klass = schema_class.model_class, issues = [])
            filter.each_with_object([[], {}]) do |(key, value), (conditions, joins)|
              key = key.to_sym

              if (attribute_definition = schema_class.attribute_definitions[key])&.filterable?
                next unless filterable_for_context?(attribute_definition)

                condition_result = build_column_condition(key, value, target_klass, issues)
                conditions << condition_result if condition_result

              elsif (association = find_filterable_association(key))
                association_conditions, association_joins = build_join_conditions(key, value, association, issues)
                conditions.concat(association_conditions)
                joins.deep_merge!(association_joins)

              else
                collect_filterable_error(key, target_klass, issues)
              end
            end
          end

          def filterable_for_context?(attribute_definition)
            filterable = attribute_definition.filterable?
            return true unless filterable.is_a?(Proc)

            schema_class.new(nil, {}).instance_eval(&filterable)
          end

          def collect_filterable_error(key, target_klass, issues)
            available = schema_class.attribute_definitions
                                    .select { |_, definition| definition.filterable? }
                                    .keys

            issues << Issue.new(
              code: :field_not_filterable,
              detail: "#{key} is not a filterable attribute on #{target_klass.name}. Available: #{available.join(', ')}",
              path: [:filter, key],
              meta: { field: key, class: target_klass.name, available: available }
            )
          end

          def build_column_condition(key, value, target_klass, issues = [])
            validate_enum_values!(key, value, target_klass, issues) if target_klass.defined_enums.key?(key.to_s)

            column_type = target_klass.type_for_attribute(key).type
            if column_type.nil?
              issues << Issue.new(
                code: :unknown_column_type,
                field: key.to_s,
                detail: "Cannot determine type for attribute '#{key}' on #{target_klass.name}",
                path: [key.to_s]
              )
              return nil
            end

            case column_type
            when :uuid
              build_uuid_where_clause(key, value, target_klass, issues)
            when :string, :text
              build_string_where_clause(key, value, target_klass, issues)
            when :date, :datetime
              build_date_where_clause(key, value, target_klass, issues)
            when :decimal, :integer, :float
              build_numeric_where_clause(key, value, target_klass, issues)
            when :boolean
              build_boolean_where_clause(key, value, target_klass, issues)
            else
              issues << Issue.new(
                code: :unsupported_column_type,
                detail: "Unsupported column type: #{column_type}",
                path: [:filter, key],
                meta: { field: key, type: column_type }
              )
              nil
            end
          end

          def validate_enum_values!(key, value, target_klass, issues = [])
            enum_values = target_klass.defined_enums[key.to_s].keys
            invalid_values = extract_values_from_filter(value) - enum_values

            return if invalid_values.empty?

            issues << Issue.new(
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

          def build_join_conditions(key, value, association, issues = [])
            reflection = schema_class.model_class.reflect_on_association(key)
            assoc_resource = association.schema_class || Apiwork::Schema::Resolver.from_association(reflection, schema)

            assoc_resource = assoc_resource.constantize if assoc_resource.is_a?(String)

            unless assoc_resource
              issues << Issue.new(
                code: :association_resource_not_found,
                detail: "Cannot find resource for association #{key}",
                path: [:filter, key],
                meta: { association: key }
              )
              return [[], {}]
            end

            association_reflection = schema_class.model_class.reflect_on_association(key)
            unless association_reflection
              issues << Issue.new(
                code: :association_not_found,
                detail: "Association #{key} not found on #{schema_class.model_class.name}",
                path: [:filter, key],
                meta: { association: key, class: schema_class.model_class.name }
              )
              return [[], {}]
            end

            nested_query = CollectionLoader.new(association_reflection.klass.all, assoc_resource, {}, nil)
            nested_conditions, nested_joins = nested_query.send(:build_where_conditions, value,
                                                                association_reflection.klass, issues)

            [nested_conditions, { key => (nested_joins.any? ? nested_joins : {}) }]
          end

          def build_uuid_where_clause(key, value, target_klass, issues = [])
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

            builder = FilterBuilder.new(
              column: column,
              field_name: key,
              issues: issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: Apiwork::Schema::Operator::NULLABLE_UUID_OPERATORS, normalizer: normalizer) do |operator, compare|
              case operator
              when :eq then column.eq(compare)
              when :in then column.in(compare)
              when :null then handle_null_operator(column, compare)
              end
            end
          end

          def build_string_where_clause(key, value, target_klass, issues = [])
            column = target_klass.arel_table[key]

            normalizer = ->(val) { val.is_a?(String) || val.nil? ? { eq: val } : val }

            builder = FilterBuilder.new(
              column: column,
              field_name: key,
              issues: issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: Apiwork::Schema::Operator::NULLABLE_STRING_OPERATORS, normalizer: normalizer) do |operator, compare|
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

          def build_date_where_clause(key, value, target_klass, issues = [])
            column = target_klass.arel_table[key]
            allow_nil = target_klass.columns_hash[key.to_s].null

            if value.is_a?(String) || value.nil?
              return handle_date_nil_value(column, key, allow_nil, issues) if value.blank?

              return column.eq(parse_date(value, key, issues))
            end

            normalizer = ->(val) { val }

            builder = FilterBuilder.new(
              column: column,
              field_name: key,
              issues: issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: Apiwork::Schema::Operator::NULLABLE_DATE_OPERATORS, normalizer: normalizer) do |operator, compare|
              if operator == :null
                handle_null_operator(column, compare)
              elsif compare.blank?
                handle_date_nil_value(column, key, allow_nil, issues)
              elsif operator == :between && compare.is_a?(Hash)
                from_date = parse_date(compare[:from] || compare['from'], key, issues)
                to_date = parse_date(compare[:to] || compare['to'], key, issues)
                next unless from_date && to_date

                column.gteq(from_date.beginning_of_day).and(column.lteq(to_date.end_of_day))
              else
                date = parse_date(compare, key, issues)
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

          def handle_date_nil_value(column, key, allow_nil, issues)
            unless allow_nil
              issues << Issue.new(
                code: :null_not_allowed,
                detail: "#{key} cannot be null",
                path: [:filter, key],
                meta: { field: key }
              )
            end

            column.eq(nil)
          end

          def build_numeric_where_clause(key, value, target_klass, issues = [])
            column = target_klass.arel_table[key]

            normalizer = ->(val) { [String, Numeric, NilClass].any? { |t| val.is_a?(t) } ? { eq: val } : val }

            builder = FilterBuilder.new(
              column: column,
              field_name: key,
              issues: issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: Apiwork::Schema::Operator::NULLABLE_NUMERIC_OPERATORS,
                                 normalizer: normalizer) do |operator, compare|
              case operator
              when :eq
                number = parse_numeric(compare, key, issues)
                column.eq(number)
              when :gt
                number = parse_numeric(compare, key, issues)
                column.gt(number)
              when :gte
                number = parse_numeric(compare, key, issues)
                column.gteq(number)
              when :lt
                number = parse_numeric(compare, key, issues)
                column.lt(number)
              when :lte
                number = parse_numeric(compare, key, issues)
                column.lteq(number)
              when :between
                if compare.is_a?(Hash)
                  from_num = parse_numeric(compare[:from] || compare['from'], key, issues)
                  to_num = parse_numeric(compare[:to] || compare['to'], key, issues)
                  next unless from_num && to_num

                  column.between(from_num..to_num)
                else
                  number = parse_numeric(compare, key, issues)
                  next unless number

                  column.between(number..number)
                end
              when :in
                numbers = Array(compare).map { |v| parse_numeric(v, key, issues) }.compact
                next if numbers.empty?

                column.in(numbers)
              when :null
                handle_null_operator(column, compare)
              end
            end
          end

          def build_boolean_where_clause(key, value, target_klass, issues = [])
            column = target_klass.arel_table[key]

            normalizer = lambda do |val|
              if [true, false, nil].include?(val) || ['true', 'false', '1', '0', 1, 0].include?(val)
                { eq: normalize_boolean(val) }
              else
                val
              end
            end

            builder = FilterBuilder.new(
              column: column,
              field_name: key,
              issues: issues,
              allowed_types: [Hash]
            )

            builder.build(value, valid_operators: Apiwork::Schema::Operator::NULLABLE_BOOLEAN_OPERATORS,
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

          def normalize_boolean(value)
            return nil if value.nil?

            [true, 'true', 1, '1'].include?(value)
          end

          def parse_date(value, field, issues = [])
            DateTime.parse(value.to_s)
          rescue ArgumentError
            issues << Issue.new(
              code: :invalid_date_format,
              detail: "'#{value}' is not a valid date",
              path: [:filter, field],
              meta: { field: field, value: value }
            )
            nil
          end

          def parse_numeric(value, field, issues = [])
            case value
            when Numeric then value
            when String then Float(value)
            else
              issues << Issue.new(
                code: :invalid_numeric_format,
                detail: "'#{value}' is not a valid number",
                path: [:filter, field],
                meta: { field: field, value: value }
              )
              nil
            end
          rescue ArgumentError
            issues << Issue.new(
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
        end
      end
    end
  end
end
