# frozen_string_literal: true

module Apiwork
  module Schema
    module Model
      # Querying - ActiveRecord-specific querying functionality
      # This module is extended into Schema::Base when model() is called
      module Querying
        # Import operators from centralized Operators module
        include Operators

        # ============================================================
        # RELATION - Main query interface
        # ============================================================

        def query(scope, params)
          query_params = extract_query_params(params)

          scope = apply_filter(scope, query_params[:filter]) if query_params[:filter].present?

          sort_params = query_params[:sort] || default_sort
          scope = apply_sort(scope, sort_params) if sort_params.present?

          scope = apply_pagination(scope, query_params[:page]) if query_params[:page].present?

          scope
        rescue ArgumentError => e
          raise Apiwork::FilterError.new(
            code: :filter_error,
            detail: "Filter error: #{e.message}",
            path: [:filter]
          )
        rescue StandardError => e
          raise Apiwork::Error.new("Query error: #{e.message}")
        end

        def extract_query_params(params)
          if params.is_a?(ActionController::Parameters)
            params = params.dup.permit!.to_h.deep_symbolize_keys
          elsif params.respond_to?(:to_h)
            params = params.to_h.deep_symbolize_keys
          end

          {
            filter: params[:filter] || {},
            sort: params[:sort],
            page: params[:page] || {},
            include: params[:include]
          }
        end

        # ============================================================
        # FILTER - Filtering logic
        # ============================================================

        def apply_filter(scope, params)
          return scope if params.blank?

          scope = case params
                  when Hash
                    conditions, joins = build_where_conditions(params)
                    result = scope.joins(joins).where(conditions.reduce(:and))
                    # Use distinct when joining associations to avoid duplicates from has_many
                    joins.present? ? result.distinct : result
                  when Array
                    # Build OR query: each array element is a separate filter that should be OR'd together
                    # Step 1: Build individual AND conditions for each filter hash
                    individual_conditions = params.map do |filter_hash|
                      conditions, _joins = build_where_conditions(filter_hash)
                      # Each filter hash may have multiple conditions - combine them with AND
                      conditions.compact.reduce(:and) if conditions.any?
                    end.compact

                    # Step 2: Combine all individual conditions with OR
                    or_condition = individual_conditions.reduce(:or) if individual_conditions.any?

                    # Step 3: Collect all joins needed
                    all_joins = params.map { |p| build_where_conditions(p)[1] }.reduce({}) { |acc, j| acc.deep_merge(j) }

                    # Step 4: Apply the OR condition and joins
                    result = scope
                    result = result.joins(all_joins) if all_joins.present?
                    result = result.where(or_condition) if or_condition
                    # Use distinct when joining associations to avoid duplicates from has_many
                    all_joins.present? ? result.distinct : result
                  end
          scope
        end

        private

        def build_where_conditions(filter, target_klass = model_class)
          filter.each_with_object([[], {}]) do |(key, value), (conditions, joins)|
            key = key.to_sym

            if (attribute_definition = attribute_definitions[key])&.filterable?
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

          new(nil, {}).instance_eval(&filterable)
        end

        def raise_filterable_error(key, target_klass)
          available = attribute_definitions
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
          return Arel.sql('1=1') if column_type.nil? # Association, not a column

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
            # Extract values from operators like { in: ['value1', 'value2'] }
            value.values.flatten.compact
          else
            []
          end
        end

        # Find filterable association
        def find_filterable_association(key)
          association_definitions[key] if association_definitions.key?(key) && association_definitions[key].filterable?
        end

        # Build association filter conditions
        def build_join_conditions(key, value, association)
          reflection = model_class.reflect_on_association(key)
          assoc_resource = association.schema_class || Apiwork::Schema::Resolver.from_association(reflection, self)

          # Constantize if string
          assoc_resource = assoc_resource.constantize if assoc_resource.is_a?(String)

          unless assoc_resource
            error = ArgumentError.new("Cannot find resource for association #{key}")
            Apiwork::Errors::Handler.handle(error, context: { association: key })
            return [[], {}]
          end

          # Get the associated model class
          association_reflection = model_class.reflect_on_association(key)
          unless association_reflection
            error = ArgumentError.new("Association #{key} not found on #{model_class.name}")
            Apiwork::Errors::Handler.handle(error, context: { association: key, class: model_class.name })
            return [[], {}]
          end

          # Build nested filter conditions using the association's resource
          nested_conditions, nested_joins = assoc_resource.send(:build_where_conditions, value,
                                                                association_reflection.klass)

          # Build join conditions
          join_conditions = {}
          join_conditions[key] = nested_joins.any? ? nested_joins : {}

          [nested_conditions, join_conditions]
        end

        # UUID conditions
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

        # String conditions with all operators
        def build_string_where_clause(key, value, target_klass)
          column = target_klass.arel_table[key]

          # Normalize simple string to hash
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

        # Date conditions with all operators
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
                # Handle between/not_between with from/to range
                if (operator == :between || operator == :not_between) && compare.is_a?(Hash)
                  from_date = parse_date(compare[:from] || compare['from']).beginning_of_day
                  to_date = parse_date(compare[:to] || compare['to']).end_of_day

                  if operator == :between
                    column.gteq(from_date).and(column.lteq(to_date))
                  else
                    # NOT BETWEEN: outside the range (before from OR after to)
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

        # Numeric conditions
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

        # Boolean conditions
        def build_boolean_where_clause(key, value, target_klass)
          column = target_klass.arel_table[key]

          # Handle hash with operators (e.g., { equal: true })
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
          # Handle direct boolean value (legacy support)
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

        # Parse helpers
        def parse_date(value)
          DateTime.parse(value.to_s)
        rescue ArgumentError => e
          error = ArgumentError.new("'#{value}' is not a valid date")
          Apiwork::Errors::Handler.handle(error, context: { value: })
          DateTime.now # Fallback value
        end

        def parse_numeric(value)
          case value
          when Numeric then value
          when String then Float(value)
          else
            error = ArgumentError.new("'#{value}' is not a valid number")
            Apiwork::Errors::Handler.handle(error, context: { value: })
            0 # Fallback value
          end
        rescue ArgumentError => e
          error = ArgumentError.new("'#{value}' is not a valid number")
          Apiwork::Errors::Handler.handle(error, context: { value: })
          0 # Fallback value
        end

        public

        # ============================================================
        # SORT - Sorting logic
        # ============================================================

        def apply_sort(scope, params)
          return scope if params.blank?

          # Convert array of hashes to single hash
          if params.is_a?(Array)
            # Merge all hashes in order
            params = params.reduce({}) { |acc, hash| acc.merge(hash) }
          end

          unless params.is_a?(Hash)
            error = ArgumentError.new('sort must be a Hash or Array of Hashes')
            Errors::Handler.handle(error, context: { params_type: params.class })
            return scope
          end

          orders, joins = build_order_clauses(params)
          scope = scope.joins(joins).order(orders)
          # Use distinct when joining associations to avoid duplicates from has_many
          scope = scope.distinct if joins.present?
          scope
        end

        def default_sort
          @default_sort || Apiwork.configuration.default_sort
        end

        private

        def build_order_clauses(params, target_klass = model_class)
          params.each_with_object([[], []]) do |(key, value), (orders, joins)|
            key = key.to_sym

            if value.is_a?(String) || value.is_a?(Symbol)
              attribute_definition = attribute_definitions[key]
              unless attribute_definition&.sortable?
                available = attribute_definitions
                            .select { |_, definition| definition.sortable? }
                            .keys
                            .join(', ')

                error = ArgumentError.new(
                  "#{key} is not sortable on #{target_klass.name}. Sortable: #{available}"
                )
                Errors::Handler.handle(error, context: { field: key, class: target_klass.name })
                next
              end

              column = target_klass.arel_table[key]
              direction = value.to_sym

              orders << case direction
                        when :asc then column.asc
                        when :desc then column.desc
                        else
                          error = ArgumentError.new("Invalid direction '#{direction}'. Use 'asc' or 'desc'")
                          Errors::Handler.handle(error, context: { field: key, direction: direction })
                          next
                        end

            elsif value.is_a?(Hash)
              association = target_klass.reflect_on_association(key)

              if association.nil?
                error = ArgumentError.new("#{key} is not a valid association on #{target_klass.name}")
                Errors::Handler.handle(error, context: { field: key, class: target_klass.name })
                next
              end

              unless association_definitions[key]&.sortable?
                error = ArgumentError.new("Association #{key} is not sortable")
                Errors::Handler.handle(error, context: { association: key })
                next
              end

              association_resource = association_definitions[key].schema_class || detect_association_resource(key)

              if association_resource.nil?
                error = ArgumentError.new("Cannot find resource for association #{key}")
                Errors::Handler.handle(error, context: { association: key })
                next
              end

              # Constantize if string
              association_resource = association_resource.constantize if association_resource.is_a?(String)

              nested_orders, nested_joins = association_resource.send(:build_order_clauses, value,
                                                                      association.klass)
              orders.concat(nested_orders)

              joins << (nested_joins.any? ? { key => nested_joins } : key)
            else
              error = ArgumentError.new("Sort value must be 'asc', 'desc', or Hash for associations")
              Errors::Handler.handle(error, context: { field: key, value_type: value.class })
            end
          end
        end

        public

        # ============================================================
        # PAGINATE - Pagination logic
        # ============================================================

        def apply_pagination(scope, params)
          page_number = params.fetch(:number, 1).to_i
          page_size = params.fetch(:size, default_page_size).to_i

          if page_number < 1
            error = ArgumentError.new('page[number] must be >= 1')
            Errors::Handler.handle(error, context: { page_number: page_number })
          end

          if page_size < 1
            error = ArgumentError.new('page[size] must be >= 1')
            Errors::Handler.handle(error, context: { page_size: page_size })
          end

          if page_size > maximum_page_size
            error = ArgumentError.new("page[size] must be <= #{maximum_page_size}")
            Errors::Handler.handle(error, context: { page_size: page_size, maximum: maximum_page_size })
          end

          page_size = [page_size, maximum_page_size].min

          scope.instance_variable_set(:@pagination_page, page_number)
          scope.instance_variable_set(:@pagination_size, page_size)

          offset = (page_number - 1) * page_size

          scope.limit(page_size).offset(offset)
        end

        def build_meta(collection)
          current = collection.instance_variable_get(:@pagination_page) || 1
          size = collection.instance_variable_get(:@pagination_size) || default_page_size

          items = collection.except(:limit, :offset).count
          total = (items.to_f / size).ceil

          page = {
            current:,
            next: (current < total ? current + 1 : nil),
            prev: (current > 1 ? current - 1 : nil),
            total:,
            items:
          }

          {
            page: Apiwork::Transform::Case.hash(page, serialize_key_transform)
          }
        end

        def default_page_size
          @default_page_size || Apiwork.configuration.default_page_size
        end

        def maximum_page_size
          @maximum_page_size || Apiwork.configuration.maximum_page_size
        end

        # ============================================================
        # INCLUDES - Association eager loading
        # ============================================================

        def apply_includes(scope, includes_param = nil)
          return scope if association_definitions.empty?

          # If specific includes provided, build hash from them
          # Otherwise, include all associations (auto_include_associations mode)
          includes_hash = if includes_param
                            build_includes_hash_from_param(includes_param)
                          else
                            @includes_hash ||= build_includes_hash
                          end

          return scope if includes_hash.empty?

          scope.includes(includes_hash)
        end

        # Build includes hash from validated includes parameter
        # Input: { comments: true } or { comments: { author: true } }
        # Output: Rails .includes format: :comments or { comments: :author }
        def build_includes_hash_from_param(includes_param)
          return {} unless includes_param.is_a?(Hash)

          includes_hash = {}
          includes_param.each do |key, value|
            key = key.to_sym
            assoc_def = association_definitions[key]
            next unless assoc_def

            if value.is_a?(TrueClass)
              # Simple include: just the association name
              includes_hash[key] = {}
            elsif value.is_a?(Hash)
              # Nested include: recursively build for associated resource
              assoc_resource = assoc_def.schema_class
              if assoc_resource.is_a?(String)
                assoc_resource = begin
                  assoc_resource.constantize
                rescue StandardError
                  nil
                end
              end

              if assoc_resource&.respond_to?(:build_includes_hash_from_param)
                nested_hash = assoc_resource.build_includes_hash_from_param(value)
                includes_hash[key] = nested_hash.any? ? nested_hash : {}
              else
                includes_hash[key] = {}
              end
            end
          end

          includes_hash
        end

        def build_includes_hash(visited = Set.new)
          includes_hash = {}
          if visited.include?(name)
            error = Apiwork::ConfigurationError.new(
              code: :circular_dependency,
              detail: "Circular dependency detected in #{name}, skipping nested includes",
              path: [name]
            )
            Apiwork::Errors::Handler.handle(error, context: { resource: name })
            return {}
          end
          visited = visited.dup.add(name)

          association_definitions.each do |assoc_name, assoc_def|
            association = model_class.reflect_on_association(assoc_name)
            next if association&.polymorphic?

            resource_class = assoc_def.schema_class || Apiwork::Schema::Resolver.from_association(association,
                                                                                                      self)
            if resource_class.respond_to?(:build_includes_hash)
              nested_includes = resource_class.build_includes_hash(visited)
              includes_hash[assoc_name] = nested_includes.any? ? nested_includes : {}
            else
              includes_hash[assoc_name] = {}
            end
          end
          includes_hash
        end
      end
    end
  end
end
