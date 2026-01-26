# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering < Adapter::Capability::Base
          class Filter
            attr_reader :issues, :representation_class

            def self.apply(relation, params, representation_class)
              filter = new(relation, representation_class)
              result = filter.filter(params)
              raise ContractError, filter.issues if filter.issues.any?

              result
            end

            def initialize(relation, representation_class, issues = [])
              @relation = relation
              @representation_class = representation_class
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

            def build_where_conditions(filter, target_klass = representation_class.model_class)
              filter.each_with_object([[], {}]) do |(key, value), (conditions, joins)|
                key = key.to_sym

                if (attribute = representation_class.attributes[key])&.filterable?
                  next unless filterable_for_context?(attribute)

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

            private

            def apply_hash_filter(params)
              logical_ops, regular_attrs = separate_logical_operators(params)

              scope = @relation

              if regular_attrs.present?
                conditions, joins = build_where_conditions(regular_attrs, representation_class.model_class)
                scope = with_joins_and_distinct(scope, joins) { |scoped| scoped.where(conditions.reduce(:and)) } if conditions.any?
              end

              scope = apply_not(scope, logical_ops[Constants::NOT]) if logical_ops.key?(Constants::NOT)
              scope = apply_or(scope, logical_ops[Constants::OR]) if logical_ops.key?(Constants::OR)
              scope = apply_and(scope, logical_ops[Constants::AND]) if logical_ops.key?(Constants::AND)

              scope
            end

            def apply_array_filter(params)
              return @relation if params.empty?

              individual_conditions = params.filter_map do |filter_hash|
                conditions, _joins = build_where_conditions(filter_hash, representation_class.model_class)
                conditions.compact.reduce(:and) if conditions.any?
              end

              or_condition = individual_conditions.reduce(:or) if individual_conditions.any?

              joins_per_filter = params.map do |filter_params|
                build_where_conditions(filter_params, representation_class.model_class)[1]
              end
              all_joins = joins_per_filter.reduce({}) { |accumulated, joins| accumulated.deep_merge(joins) }

              with_joins_and_distinct(@relation, all_joins) do |scope|
                or_condition ? scope.where(or_condition) : scope
              end
            end

            def apply_not(scope, filter_params)
              condition, joins = build_conditions_recursive(filter_params)
              return scope if condition.nil?

              with_joins_and_distinct(scope, joins) { |scoped| scoped.where.not(condition) }
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

              with_joins_and_distinct(scope, all_joins) do |scoped|
                or_condition ? scoped.where(or_condition) : scoped
              end
            end

            def apply_and(scope, conditions_array)
              return scope if conditions_array.blank?

              conditions_array.reduce(scope) do |current_scope, filter_hash|
                Filter.new(current_scope, representation_class, @issues).filter(filter_hash)
              end
            end

            def build_conditions_recursive(filter_params)
              return [nil, {}] if filter_params.blank?
              return [nil, {}] unless filter_params.is_a?(Hash)

              logical_ops, regular_attrs = separate_logical_operators(filter_params)

              conditions = []
              all_joins = {}

              if regular_attrs.present?
                attribute_conditions, joins = build_where_conditions(regular_attrs, representation_class.model_class)
                conditions << attribute_conditions.reduce(:and) if attribute_conditions.any?
                all_joins = all_joins.deep_merge(joins)
              end

              if logical_ops.key?(Constants::AND)
                cond, joins = process_logical_operator(logical_ops[Constants::AND], :and)
                conditions << cond if cond
                all_joins = all_joins.deep_merge(joins)
              end

              if logical_ops.key?(Constants::OR)
                cond, joins = process_logical_operator(logical_ops[Constants::OR], :or)
                conditions << cond if cond
                all_joins = all_joins.deep_merge(joins)
              end

              if logical_ops.key?(Constants::NOT)
                not_cond, joins = build_conditions_recursive(logical_ops[Constants::NOT])
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

            def filterable_for_context?(attribute)
              filterable = attribute.filterable?
              return true unless filterable.is_a?(Proc)

              representation_class.new(nil, {}).instance_eval(&filterable)
            end

            def collect_filterable_error(key, target_klass)
              available = representation_class.attributes
                .values
                .select(&:filterable?)
                .map(&:name)

              @issues << Issue.new(
                :field_not_filterable,
                'Not filterable',
                meta: { available:, field: key },
                path: [:filter, key],
              )
            end

            def build_column_condition(key, value, target_klass)
              validate_enum_values!(key, value, target_klass) if target_klass.defined_enums.key?(key.to_s)

              association = representation_class.polymorphic_association_for_type_column(key)
              value = transform_polymorphic_filter_value(value, association) if association

              union = representation_class.sti_union_for_type_column(key)
              value = transform_sti_filter_value(value, union) if union

              column_type = target_klass.type_for_attribute(key).type
              if column_type.nil?
                @issues << Issue.new(
                  :column_unknown,
                  'Unknown column type',
                  meta: { field: key },
                  path: [:filter, key],
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
              when :decimal, :integer, :number
                build_numeric_where_clause(key, value, target_klass)
              when :boolean
                build_boolean_where_clause(key, value, target_klass)
              else
                @issues << Issue.new(
                  :column_unsupported,
                  'Unsupported column type',
                  meta: { field: key, type: column_type },
                  path: [:filter, key],
                )
                nil
              end
            end

            def validate_enum_values!(key, value, target_klass)
              enum_values = target_klass.defined_enums[key.to_s].keys
              invalid_values = extract_values_from_filter(value) - enum_values

              return if invalid_values.empty?

              @issues << Issue.new(
                :enum_invalid,
                'Invalid enum value',
                meta: {
                  allowed: enum_values,
                  field: key,
                  value: invalid_values,
                },
                path: [:filter, key],
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

            def transform_polymorphic_filter_value(value, association)
              mapping = build_polymorphic_type_mapping(association)

              case value
              when String
                mapping[value] || value
              when Hash
                value.transform_values { |v| transform_polymorphic_filter_value(v, association) }
              when Array
                value.map { |v| transform_polymorphic_filter_value(v, association) }
              else
                value
              end
            end

            def build_polymorphic_type_mapping(association)
              association.polymorphic.each_with_object({}) do |representation_class, mapping|
                api_value = (representation_class.type_name || representation_class.model_class.polymorphic_name).to_s
                db_value = representation_class.model_class.polymorphic_name
                mapping[api_value] = db_value
              end
            end

            def transform_sti_filter_value(value, union)
              mapping = build_sti_type_mapping(union)

              case value
              when String
                mapping[value] || value
              when Hash
                value.transform_values { |v| transform_sti_filter_value(v, union) }
              when Array
                value.map { |v| transform_sti_filter_value(v, union) }
              else
                value
              end
            end

            def build_sti_type_mapping(union)
              union.variants.values.each_with_object({}) do |variant, mapping|
                mapping[variant.tag.to_s] = variant.type
              end
            end

            def find_filterable_association(key)
              association = representation_class.associations[key]
              return unless association
              return unless association.filterable?

              association
            end

            def build_join_conditions(key, value, association)
              reflection = representation_class.model_class.reflect_on_association(key)
              association_resource = association.representation_class || infer_association_representation(reflection)

              unless association_resource
                @issues << Issue.new(
                  :association_representation_missing,
                  'Association representation missing',
                  meta: { association: key },
                  path: [:filter, key],
                )
                return [[], {}]
              end

              association_reflection = representation_class.model_class.reflect_on_association(key)
              unless association_reflection
                @issues << Issue.new(
                  :association_not_found,
                  'Association not found',
                  meta: { association: key },
                  path: [:filter, key],
                )
                return [[], {}]
              end

              nested_query = Filter.new(association_reflection.klass.all, association_resource, @issues)
              nested_conditions, nested_joins = nested_query.build_where_conditions(value, association_reflection.klass)

              [nested_conditions, { key => (nested_joins.any? ? nested_joins : {}) }]
            end

            def build_uuid_where_clause(key, value, target_klass)
              column = target_klass.arel_table[key]

              normalizer = lambda do |value|
                case value
                when String
                  value.include?(',') ? { in: value.split(',') } : { eq: value }
                when Array
                  { in: value }
                else
                  value
                end
              end

              builder = Builder.new(column, key, allowed_types: [Hash], issues: @issues)

              builder.build(value, normalizer:, valid_operators: Constants::NULLABLE_UUID_OPERATORS) do |operator, compare|
                case operator
                when :eq then column.eq(compare)
                when :in then column.in(compare)
                when :null then handle_null_operator(column, compare)
                end
              end
            end

            def build_string_where_clause(key, value, target_klass)
              column = target_klass.arel_table[key]

              normalizer = ->(value) { value.is_a?(String) || value.nil? ? { eq: value } : value }

              builder = Builder.new(column, key, allowed_types: [Hash], issues: @issues)

              builder.build(
                value,
                normalizer:,
                valid_operators: Constants::NULLABLE_STRING_OPERATORS,
              ) do |operator, compare|
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

              normalizer = ->(value) { value }

              builder = Builder.new(column, key, allowed_types: [Hash], issues: @issues)

              builder.build(value, normalizer:, valid_operators: Constants::NULLABLE_DATE_OPERATORS) do |operator, compare|
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
                  :value_null,
                  'Cannot be null',
                  meta: { field: key },
                  path: [:filter, key],
                )
              end

              column.eq(nil)
            end

            def build_numeric_where_clause(key, value, target_klass)
              column = target_klass.arel_table[key]

              normalizer = ->(value) { [String, Numeric, NilClass].any? { |type| value.is_a?(type) } ? { eq: value } : value }

              builder = Builder.new(column, key, allowed_types: [Hash], issues: @issues)

              builder.build(
                value,
                normalizer:,
                valid_operators: Constants::NULLABLE_NUMERIC_OPERATORS,
              ) do |operator, compare|
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
                  numbers = Array(compare).filter_map { |value| parse_numeric(value, key) }
                  next if numbers.empty?

                  column.in(numbers)
                when :null
                  handle_null_operator(column, compare)
                end
              end
            end

            def build_boolean_where_clause(key, value, target_klass)
              column = target_klass.arel_table[key]

              normalizer = lambda do |value|
                if [true, false, nil].include?(value) || ['true', 'false', '1', '0', 1, 0].include?(value)
                  { eq: normalize_boolean(value) }
                else
                  value
                end
              end

              builder = Builder.new(column, key, allowed_types: [Hash], issues: @issues)

              builder.build(
                value,
                normalizer:,
                valid_operators: Constants::NULLABLE_BOOLEAN_OPERATORS,
              ) do |operator, compare|
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
                :date_invalid,
                'Invalid date',
                meta: { field:, value: },
                path: [:filter, field],
              )
              nil
            end

            def parse_numeric(value, field)
              case value
              when Numeric then value
              when String then Float(value)
              else
                @issues << Issue.new(
                  :number_invalid,
                  'Invalid number',
                  meta: { field:, value: },
                  path: [:filter, field],
                )
                nil
              end
            rescue ArgumentError
              @issues << Issue.new(
                :number_invalid,
                'Invalid number',
                meta: { field:, value: },
                path: [:filter, field],
              )
              nil
            end

            def sqlite_adapter?
              @sqlite_adapter ||= representation_class.model_class.connection.adapter_name == 'SQLite'
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
              [params.slice(*Constants::LOGICAL_OPERATORS), params.except(*Constants::LOGICAL_OPERATORS)]
            end

            def with_joins_and_distinct(scope, joins)
              result = yield(joins.present? ? scope.joins(joins) : scope)
              joins.present? ? result.distinct : result
            end

            def infer_association_representation(reflection)
              return nil if reflection.polymorphic?

              namespace = representation_class.name.deconstantize
              "#{namespace}::#{reflection.klass.name}Representation".safe_constantize
            end
          end
        end
      end
    end
  end
end
