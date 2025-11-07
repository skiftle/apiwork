# frozen_string_literal: true

module Apiwork
  class Query
    module Filtering
      include Apiwork::Schema::Operators

      def apply_filter(scope, params)
        return scope if params.blank?

        scope = case params
                when Hash
                  conditions, joins = build_where_conditions(params)
                  result = scope.joins(joins).where(conditions.reduce(:and))
                  joins.present? ? result.distinct : result
                when Array
                  individual_conditions = params.map do |filter_hash|
                    conditions, _joins = build_where_conditions(filter_hash)
                    conditions.compact.reduce(:and) if conditions.any?
                  end.compact

                  or_condition = individual_conditions.reduce(:or) if individual_conditions.any?
                  all_joins = params.map { |p| build_where_conditions(p)[1] }.reduce({}) { |acc, j| acc.deep_merge(j) }

                  result = scope
                  result = result.joins(all_joins) if all_joins.present?
                  result = result.where(or_condition) if or_condition
                  all_joins.present? ? result.distinct : result
                end
        scope
      end

      private

      def build_where_conditions(filter, target_klass = schema.model_class)
        filter.each_with_object([[], {}]) do |(key, value), (conditions, joins)|
          key = key.to_sym

          if (attribute_definition = schema.attribute_definitions[key])&.filterable?
            next unless filterable_for_context?(attribute_definition)

            conditions << build_column_condition(key, value, target_klass)

          elsif (association = find_filterable_association(key))
            association_conditions, association_joins = build_join_conditions(key, value, association)
            conditions.concat(association_conditions)
            joins.deep_merge!(association_joins)

          else
            raise_filterable_error(key, target_klass)
          end
        end
      end

      def filterable_for_context?(attribute_definition)
        filterable = attribute_definition.filterable?
        return true unless filterable.is_a?(Proc)

        schema.new(nil, {}).instance_eval(&filterable)
      end

      def raise_filterable_error(key, target_klass)
        available = schema.attribute_definitions
                          .select { |_, definition| definition.filterable? }
                          .keys
                          .join(', ')

        error = ArgumentError.new(
          "#{key} is not a filterable attribute on #{target_klass.name}. Available: #{available}"
        )

        Errors::Handler.handle(error, context: { field: key, class: target_klass.name })
      end

      def build_column_condition(key, value, target_klass)
        validate_enum_values!(key, value, target_klass) if target_klass.defined_enums.key?(key.to_s)

        column_type = target_klass.type_for_attribute(key).type
        return Arel.sql('1=1') if column_type.nil?

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
          error = ArgumentError.new("Unsupported column type: #{column_type}")
          Errors::Handler.handle(error, context: { field: key, type: column_type })
        end
      end

      def validate_enum_values!(key, value, target_klass)
        enum_values = target_klass.defined_enums[key.to_s].keys

        values_to_check = extract_values_from_filter(value)
        invalid_values = values_to_check - enum_values

        return if invalid_values.empty?

        error = ArgumentError.new(
          "Invalid #{key} value(s): #{invalid_values.join(', ')}. " \
          "Valid values: #{enum_values.join(', ')}"
        )
        Apiwork::Errors::Handler.handle(error,
                                        context: { field: key, invalid: invalid_values, valid: enum_values })
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
        schema.association_definitions[key] if schema.association_definitions.key?(key) && schema.association_definitions[key].filterable?
      end

      def build_join_conditions(key, value, association)
        reflection = schema.model_class.reflect_on_association(key)
        assoc_resource = association.schema_class || Apiwork::Schema::Resolver.from_association(reflection, schema)

        assoc_resource = assoc_resource.constantize if assoc_resource.is_a?(String)

        unless assoc_resource
          error = ArgumentError.new("Cannot find resource for association #{key}")
          Apiwork::Errors::Handler.handle(error, context: { association: key })
          return [[], {}]
        end

        association_reflection = schema.model_class.reflect_on_association(key)
        unless association_reflection
          error = ArgumentError.new("Association #{key} not found on #{schema.model_class.name}")
          Apiwork::Errors::Handler.handle(error, context: { association: key, class: schema.model_class.name })
          return [[], {}]
        end

        # Use Query class for nested filtering
        nested_query = Apiwork::Query.new(association_reflection.klass.all, schema: assoc_resource)
        nested_conditions, nested_joins = nested_query.send(:build_where_conditions, value, association_reflection.klass)

        join_conditions = {}
        join_conditions[key] = nested_joins.any? ? nested_joins : {}

        [nested_conditions, join_conditions]
      end

      def build_uuid_where_clause(key, value, target_klass)
        column = target_klass.arel_table[key]

        case value
        when String
          value.include?(',') ? column.in(value.split(',')) : column.eq(value)
        when Array
          column.in(value)
        else
          error = ArgumentError.new('UUID value must be String or Array')
          Apiwork::Errors::Handler.handle(error, context: { field: key, value_type: value.class })
        end
      end

      def build_string_where_clause(key, value, target_klass)
        column = target_klass.arel_table[key]

        value = { equal: value } if value.is_a?(String) || value.nil?

        unless value.is_a?(Hash)
          error = ArgumentError.new('Expected Hash for string filter')
          Errors::Handler.handle(error, context: { field: key, value_type: value.class })
          return column.eq(nil)
        end

        value.map do |operator, compare|
          operator = operator.to_sym

          if STRING_OPERATORS.exclude?(operator)
            error = ArgumentError.new(
              "Invalid operator '#{operator}' for string. Valid: #{STRING_OPERATORS.join(', ')}"
            )
            Errors::Handler.handle(error, context: { field: key, operator: operator })
            next
          end

          case operator
          when :equal then column.eq(compare)
          when :not_equal then column.not_eq(compare)
          when :contains then column.matches("%#{compare}%")
          when :not_contains then column.does_not_match("%#{compare}%")
          when :starts_with then column.matches("#{compare}%")
          when :ends_with then column.matches("%#{compare}")
          when :in then column.in(compare)
          when :not_in then column.not_in(compare)
          end
        end.reduce(:and)
      end

      def build_date_where_clause(key, value, target_klass)
        column = target_klass.arel_table[key]
        allow_nil = target_klass.columns_hash[key.to_s].null

        case value
        when String, nil
          if value.blank?
            unless allow_nil
              error = ArgumentError.new("#{key} cannot be null")
              Errors::Handler.handle(error, context: { field: key })
              return column.eq(nil)
            end

            column.eq(nil)
          else
            column.eq(parse_date(value))
          end
        when Hash
          value.map do |operator, compare|
            operator = operator.to_sym

            if DATE_OPERATORS.exclude?(operator)
              error = ArgumentError.new(
                "Invalid operator '#{operator}' for date. Valid: #{DATE_OPERATORS.join(', ')}"
              )
              Errors::Handler.handle(error, context: { field: key, operator: operator })
              next
            end

            if compare.blank?
              unless allow_nil
                error = ArgumentError.new("#{key} cannot be null")
                Errors::Handler.handle(error, context: { field: key })
                next
              end

              operator == :equal ? column.eq(nil) : column.not_eq(nil)
            else
              if (operator == :between || operator == :not_between) && compare.is_a?(Hash)
                from_date = parse_date(compare[:from] || compare['from']).beginning_of_day
                to_date = parse_date(compare[:to] || compare['to']).end_of_day

                if operator == :between
                  column.gteq(from_date).and(column.lteq(to_date))
                else
                  Arel::Nodes::Grouping.new(
                    column.lt(from_date).or(column.gt(to_date))
                  )
                end
              else
                date = parse_date(compare)
                case operator
                when :equal then column.eq(date)
                when :not_equal then column.not_eq(date)
                when :greater_than then column.gt(date)
                when :greater_than_or_equal_to then column.gteq(date)
                when :less_than then column.lt(date)
                when :less_than_or_equal_to then column.lteq(date)
                when :in then column.in(Array(date))
                when :not_in then column.not_in(Array(date))
                end
              end
            end
          end.compact.reduce(:and)
        else
          error = ArgumentError.new('Date value must be String, Hash, or nil')
          Apiwork::Errors::Handler.handle(error, context: { field: key, value_type: value.class })
        end
      end

      def build_numeric_where_clause(key, value, target_klass)
        column = target_klass.arel_table[key]

        case value
        when String, Numeric, nil
          column.eq(parse_numeric(value))
        when Hash
          value.map do |operator, compare|
            operator = operator.to_sym

            if NUMERIC_OPERATORS.exclude?(operator)
              error = ArgumentError.new(
                "Invalid operator '#{operator}' for numeric. Valid: #{NUMERIC_OPERATORS.join(', ')}"
              )
              Errors::Handler.handle(error, context: { field: key, operator: operator })
              next
            end

            case operator
            when :equal
              number = parse_numeric(compare)
              column.eq(number)
            when :not_equal
              number = parse_numeric(compare)
              column.not_eq(number)
            when :greater_than
              number = parse_numeric(compare)
              column.gt(number)
            when :greater_than_or_equal_to
              number = parse_numeric(compare)
              column.gteq(number)
            when :less_than
              number = parse_numeric(compare)
              column.lt(number)
            when :less_than_or_equal_to
              number = parse_numeric(compare)
              column.lteq(number)
            when :between
              number = parse_numeric(compare)
              column.between(number..number)
            when :not_between
              number = parse_numeric(compare)
              column.not_between(number..number)
            when :in
              numbers = Array(compare).map { |v| parse_numeric(v) }
              column.in(numbers)
            when :not_in
              numbers = Array(compare).map { |v| parse_numeric(v) }
              column.not_in(numbers)
            end
          end.compact.reduce(:and)
        else
          error = ArgumentError.new('Numeric value must be String, Numeric, Hash, or nil')
          Apiwork::Errors::Handler.handle(error, context: { field: key, value_type: value.class })
        end
      end

      def build_boolean_where_clause(key, value, target_klass)
        column = target_klass.arel_table[key]

        if value.is_a?(Hash)
          operator, operand = value.first
          bool_value = normalize_boolean(operand)

          case operator.to_sym
          when :equal
            column.eq(bool_value)
          when :not_equal
            column.not_eq(bool_value)
          else
            error = ArgumentError.new("Unsupported boolean operator: #{operator}")
            Apiwork::Errors::Handler.handle(error, context: { field: key, operator: })
          end
        elsif [true, false, nil].include?(value) || ['true', 'false', '1', '0', 1, 0].include?(value)
          bool_value = normalize_boolean(value)
          column.eq(bool_value)
        else
          error = ArgumentError.new('Boolean value must be true, false, or nil')
          Apiwork::Errors::Handler.handle(error, context: { field: key, value: })
        end
      end

      def normalize_boolean(value)
        return nil if value.nil?
        [true, 'true', 1, '1'].include?(value)
      end

      def parse_date(value)
        DateTime.parse(value.to_s)
      rescue ArgumentError => e
        error = ArgumentError.new("'#{value}' is not a valid date")
        Apiwork::Errors::Handler.handle(error, context: { value: })
        DateTime.now
      end

      def parse_numeric(value)
        case value
        when Numeric then value
        when String then Float(value)
        else
          error = ArgumentError.new("'#{value}' is not a valid number")
          Apiwork::Errors::Handler.handle(error, context: { value: })
          0
        end
      rescue ArgumentError => e
        error = ArgumentError.new("'#{value}' is not a valid number")
        Apiwork::Errors::Handler.handle(error, context: { value: })
        0
      end
    end
  end
end
