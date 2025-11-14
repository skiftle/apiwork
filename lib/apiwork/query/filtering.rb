# frozen_string_literal: true

module Apiwork
  class Query
    module Filtering
      include Apiwork::Schema::Operators

      def apply_filter(scope, params, issues = [])
        return scope if params.blank?

        case params
        when Hash
          # Separate logical operators from regular attributes
          logical_ops = params.slice(:_and, :_or, :_not)
          regular_attrs = params.except(:_and, :_or, :_not)

          # Apply regular attributes first (if any)
          if regular_attrs.present?
            conditions, joins = build_where_conditions(regular_attrs, schema.model_class, issues)
            result = scope.joins(joins).where(conditions.reduce(:and))
            scope = joins.present? ? result.distinct : result
          end

          # Then apply logical operators (if any)
          scope = apply_not(scope, logical_ops[:_not], issues) if logical_ops.key?(:_not)
          scope = apply_or(scope, logical_ops[:_or], issues) if logical_ops.key?(:_or)
          scope = apply_and(scope, logical_ops[:_and], issues) if logical_ops.key?(:_and)

          scope
        when Array
          # Array format = OR logic (existing functionality)
          individual_conditions = params.map do |filter_hash|
            conditions, _joins = build_where_conditions(filter_hash, schema.model_class, issues)
            conditions.compact.reduce(:and) if conditions.any?
          end.compact

          or_condition = individual_conditions.reduce(:or) if individual_conditions.any?
          all_joins = params.map { |p| build_where_conditions(p, schema.model_class, issues)[1] }.reduce({}) { |acc, j| acc.deep_merge(j) }

          result = scope
          result = result.joins(all_joins) if all_joins.present?
          result = result.where(or_condition) if or_condition
          all_joins.present? ? result.distinct : result
        end
      end

      private

      # Apply NOT operator - negates the entire filter expression
      # Recursively processes the filter and negates the result
      def apply_not(scope, filter_params, issues = [])
        # Use build_conditions_recursive to handle nested logical operators
        condition, joins = build_conditions_recursive(filter_params, issues)

        return scope if condition.nil?

        result = scope.joins(joins)
        result = result.where.not(condition)
        joins.present? ? result.distinct : result
      end

      # Apply OR operator - combines multiple filter expressions with OR
      # Each element in the array is recursively processed
      # Handles both regular filters and nested logical operators
      def apply_or(scope, conditions_array, issues = [])
        return scope if conditions_array.blank?

        or_conditions = []
        all_joins = {}

        conditions_array.each_with_index do |filter_hash, _idx|
          # Build conditions recursively (handles nested logical operators)
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

      # Apply AND operator - combines multiple filter expressions with AND
      # Each element is recursively processed and chained
      def apply_and(scope, conditions_array, issues = [])
        return scope if conditions_array.blank?

        conditions_array.reduce(scope) do |current_scope, filter_hash|
          apply_filter(current_scope, filter_hash, issues)
        end
      end

      # Build Arel conditions recursively, handling logical operators
      # Returns [condition, joins] where condition is an Arel node
      def build_conditions_recursive(filter_params, issues = [])
        return [nil, {}] if filter_params.blank?
        return [nil, {}] unless filter_params.is_a?(Hash)

        # Separate logical operators from regular attributes
        logical_ops = filter_params.slice(:_and, :_or, :_not)
        regular_attrs = filter_params.except(:_and, :_or, :_not)

        conditions = []
        all_joins = {}

        # Build conditions for regular attributes
        if regular_attrs.present?
          attr_conditions, joins = build_where_conditions(regular_attrs, schema.model_class, issues)
          conditions << attr_conditions.reduce(:and) if attr_conditions.any?
          all_joins = all_joins.deep_merge(joins)
        end

        # Handle _and operator
        if logical_ops.key?(:_and)
          cond, joins = process_logical_operator(logical_ops[:_and], :and, issues)
          conditions << cond if cond
          all_joins = all_joins.deep_merge(joins)
        end

        # Handle _or operator
        if logical_ops.key?(:_or)
          cond, joins = process_logical_operator(logical_ops[:_or], :or, issues)
          conditions << cond if cond
          all_joins = all_joins.deep_merge(joins)
        end

        # Handle _not operator
        if logical_ops.key?(:_not)
          not_cond, joins = build_conditions_recursive(logical_ops[:_not], issues)
          conditions << not_cond.not if not_cond
          all_joins = all_joins.deep_merge(joins)
        end

        # Combine all conditions with AND
        final_condition = conditions.compact.reduce(:and)
        [final_condition, all_joins]
      end

      # Process logical operators (_and, _or) by recursively building conditions
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

      def build_where_conditions(filter, target_klass = schema.model_class, issues = [])
        filter.each_with_object([[], {}]) do |(key, value), (conditions, joins)|
          key = key.to_sym

          if (attribute_definition = schema.attribute_definitions[key])&.filterable?
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

        schema.new(nil, {}).instance_eval(&filterable)
      end

      def collect_filterable_error(key, target_klass, issues)
        available = schema.attribute_definitions
                          .select { |_, definition| definition.filterable? }
                          .keys

        issues << Issue.new(
          code: :field_not_filterable,
          message: "#{key} is not a filterable attribute on #{target_klass.name}. Available: #{available.join(', ')}",
          path: [:filter, key],
          meta: { field: key, class: target_klass.name, available: available }
        )
      end

      def build_column_condition(key, value, target_klass, issues = [])
        validate_enum_values!(key, value, target_klass, issues) if target_klass.defined_enums.key?(key.to_s)

        column_type = target_klass.type_for_attribute(key).type
        return Arel.sql('1=1') if column_type.nil?

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
            message: "Unsupported column type: #{column_type}",
            path: [:filter, key],
            meta: { field: key, type: column_type }
          )
          nil
        end
      end

      def validate_enum_values!(key, value, target_klass, issues = [])
        enum_values = target_klass.defined_enums[key.to_s].keys

        values_to_check = extract_values_from_filter(value)
        invalid_values = values_to_check - enum_values

        return if invalid_values.empty?

        issues << Issue.new(
          code: :invalid_enum_value,
          message: "Invalid #{key} value(s): #{invalid_values.join(', ')}. Valid values: #{enum_values.join(', ')}",
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
        association = schema.association_definitions[key]
        return unless association
        return unless association.filterable?

        association
      end

      def build_join_conditions(key, value, association, issues = [])
        reflection = schema.model_class.reflect_on_association(key)
        assoc_resource = association.schema_class || Apiwork::Schema::Resolver.from_association(reflection, schema)

        assoc_resource = assoc_resource.constantize if assoc_resource.is_a?(String)

        unless assoc_resource
          issues << Issue.new(
            code: :association_resource_not_found,
            message: "Cannot find resource for association #{key}",
            path: [:filter, key],
            meta: { association: key }
          )
          return [[], {}]
        end

        association_reflection = schema.model_class.reflect_on_association(key)
        unless association_reflection
          issues << Issue.new(
            code: :association_not_found,
            message: "Association #{key} not found on #{schema.model_class.name}",
            path: [:filter, key],
            meta: { association: key, class: schema.model_class.name }
          )
          return [[], {}]
        end

        # Use Query class for nested filtering
        nested_query = Apiwork::Query.new(association_reflection.klass.all, schema: assoc_resource)
        nested_conditions, nested_joins = nested_query.send(:build_where_conditions, value,
                                                            association_reflection.klass, issues)

        join_conditions = {}
        join_conditions[key] = nested_joins.any? ? nested_joins : {}

        [nested_conditions, join_conditions]
      end

      def build_uuid_where_clause(key, value, target_klass, issues = [])
        column = target_klass.arel_table[key]

        case value
        when String
          value.include?(',') ? column.in(value.split(',')) : column.eq(value)
        when Array
          column.in(value)
        else
          issues << Issue.new(
            code: :invalid_uuid_value_type,
            message: 'UUID value must be String or Array',
            path: [:filter, key],
            meta: { field: key, value_type: value.class.name }
          )
          nil
        end
      end

      def build_string_where_clause(key, value, target_klass, issues = [])
        column = target_klass.arel_table[key]

        value = { eq: value } if value.is_a?(String) || value.nil?

        unless value.is_a?(Hash)
          issues << Issue.new(
            code: :invalid_string_filter_type,
            message: 'Expected Hash for string filter',
            path: [:filter, key],
            meta: { field: key, value_type: value.class.name }
          )
          return column.eq(nil)
        end

        value.map do |operator, compare|
          operator = operator.to_sym

          if STRING_OPERATORS.exclude?(operator)
            issues << Issue.new(
              code: :invalid_string_operator,
              message: "Invalid operator '#{operator}' for string. Valid: #{STRING_OPERATORS.join(', ')}",
              path: [:filter, key, operator],
              meta: { field: key, operator: operator, valid_operators: STRING_OPERATORS }
            )
            next
          end

          case operator
          when :eq then column.eq(compare)
          when :contains then column.matches("%#{compare}%")
          when :starts_with then column.matches("#{compare}%")
          when :ends_with then column.matches("%#{compare}")
          when :in then column.in(compare)
          end
        end.reduce(:and)
      end

      def build_date_where_clause(key, value, target_klass, issues = [])
        column = target_klass.arel_table[key]
        allow_nil = target_klass.columns_hash[key.to_s].null

        case value
        when String, nil
          if value.blank?
            unless allow_nil
              issues << Issue.new(
                code: :null_not_allowed,
                message: "#{key} cannot be null",
                path: [:filter, key],
                meta: { field: key }
              )
              return column.eq(nil)
            end

            column.eq(nil)
          else
            column.eq(parse_date(value, key, issues))
          end
        when Hash
          value.map do |operator, compare|
            operator = operator.to_sym

            if DATE_OPERATORS.exclude?(operator)
              issues << Issue.new(
                code: :invalid_date_operator,
                message: "Invalid operator '#{operator}' for date. Valid: #{DATE_OPERATORS.join(', ')}",
                path: [:filter, key, operator],
                meta: { field: key, operator: operator, valid_operators: DATE_OPERATORS }
              )
              next
            end

            if compare.blank?
              unless allow_nil
                issues << Issue.new(
                  code: :null_not_allowed,
                  message: "#{key} cannot be null",
                  path: [:filter, key],
                  meta: { field: key }
                )
                next
              end

              column.eq(nil)
            elsif operator == :between && compare.is_a?(Hash)
              from_date = parse_date(compare[:from] || compare['from'], key, issues).beginning_of_day
              to_date = parse_date(compare[:to] || compare['to'], key, issues).end_of_day
              column.gteq(from_date).and(column.lteq(to_date))
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
          end.compact.reduce(:and)
        else
          issues << Issue.new(
            code: :invalid_date_value_type,
            message: 'Date value must be String, Hash, or nil',
            path: [:filter, key],
            meta: { field: key, value_type: value.class.name }
          )
          nil
        end
      end

      def build_numeric_where_clause(key, value, target_klass, issues = [])
        column = target_klass.arel_table[key]

        case value
        when String, Numeric, nil
          column.eq(parse_numeric(value, key, issues))
        when Hash
          value.map do |operator, compare|
            operator = operator.to_sym

            if NUMERIC_OPERATORS.exclude?(operator)
              issues << Issue.new(
                code: :invalid_numeric_operator,
                message: "Invalid operator '#{operator}' for numeric. Valid: #{NUMERIC_OPERATORS.join(', ')}",
                path: [:filter, key, operator],
                meta: { field: key, operator: operator, valid_operators: NUMERIC_OPERATORS }
              )
              next
            end

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
                column.between(from_num..to_num)
              else
                number = parse_numeric(compare, key, issues)
                column.between(number..number)
              end
            when :in
              numbers = Array(compare).map { |v| parse_numeric(v, key, issues) }
              column.in(numbers)
            end
          end.compact.reduce(:and)
        else
          issues << Issue.new(
            code: :invalid_numeric_value_type,
            message: 'Numeric value must be String, Numeric, Hash, or nil',
            path: [:filter, key],
            meta: { field: key, value_type: value.class.name }
          )
          nil
        end
      end

      def build_boolean_where_clause(key, value, target_klass, issues = [])
        column = target_klass.arel_table[key]

        if value.is_a?(Hash)
          operator, operand = value.first
          bool_value = normalize_boolean(operand)

          case operator.to_sym
          when :eq
            column.eq(bool_value)
          else
            issues << Issue.new(
              code: :unsupported_boolean_operator,
              message: "Unsupported boolean operator: #{operator}. Only 'eq' is supported.",
              path: [:filter, key, operator],
              meta: { field: key, operator: operator }
            )
            nil
          end
        elsif [true, false, nil].include?(value) || ['true', 'false', '1', '0', 1, 0].include?(value)
          bool_value = normalize_boolean(value)
          column.eq(bool_value)
        else
          issues << Issue.new(
            code: :invalid_boolean_value,
            message: 'Boolean value must be true, false, or nil',
            path: [:filter, key],
            meta: { field: key, value: value }
          )
          nil
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
          message: "'#{value}' is not a valid date",
          path: [:filter, field],
          meta: { field: field, value: value }
        )
        DateTime.now
      end

      def parse_numeric(value, field, issues = [])
        case value
        when Numeric then value
        when String then Float(value)
        else
          issues << Issue.new(
            code: :invalid_numeric_format,
            message: "'#{value}' is not a valid number",
            path: [:filter, field],
            meta: { field: field, value: value }
          )
          0
        end
      rescue ArgumentError
        issues << Issue.new(
          code: :invalid_numeric_format,
          message: "'#{value}' is not a valid number",
          path: [:filter, field],
          meta: { field: field, value: value }
        )
        0
      end
    end
  end
end
