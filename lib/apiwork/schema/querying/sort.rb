# frozen_string_literal: true

module Apiwork
  module Schema
    module Querying
      module Sort
        extend ActiveSupport::Concern

        class_methods do
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
        end
      end
    end
  end
end
