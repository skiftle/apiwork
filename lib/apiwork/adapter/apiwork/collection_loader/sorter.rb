# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class Sorter
          attr_reader :schema_class

          def self.sort(relation, schema_class, sort_params, issues)
            new(relation, schema_class, issues).sort(sort_params)
          end

          def initialize(relation, schema_class, issues)
            @relation = relation
            @schema_class = schema_class
            @issues = issues
          end

          def sort(params)
            return @relation if params.blank?

            params = params.reduce({}) { |acc, hash| acc.merge(hash) } if params.is_a?(Array)

            unless params.is_a?(Hash)
              @issues << Issue.new(
                code: :invalid_sort_params_type,
                detail: 'sort must be a Hash or Array of Hashes',
                path: [:sort],
                meta: { params_type: params.class.name }
              )
              return @relation
            end

            orders, joins = build_order_clauses(params, schema_class.model_class)
            scope = @relation.joins(joins).order(orders)
            scope = scope.distinct if joins.present?
            scope
          end

          private

          def build_order_clauses(params, target_klass = schema_class.model_class)
            params.each_with_object([[], []]) do |(key, value), (orders, joins)|
              key = key.to_sym

              if value.is_a?(String) || value.is_a?(Symbol)
                attribute_definition = schema_class.attribute_definitions[key]
                unless attribute_definition&.sortable?
                  available = schema_class.attribute_definitions
                                          .select { |_, definition| definition.sortable? }
                                          .keys

                  @issues << Issue.new(
                    code: :field_not_sortable,
                    detail: "#{key} is not sortable on #{target_klass.name}. Sortable: #{available.join(', ')}",
                    path: [:sort, key],
                    meta: { field: key, class: target_klass.name, available: available }
                  )
                  next
                end

                column = target_klass.arel_table[key]
                direction = value.to_sym

                orders << case direction
                          when :asc then column.asc
                          when :desc then column.desc
                          else
                            @issues << Issue.new(
                              code: :invalid_sort_direction,
                              detail: "Invalid direction '#{direction}'. Use 'asc' or 'desc'",
                              path: [:sort, key],
                              meta: { field: key, direction: direction, valid_directions: [:asc, :desc] }
                            )
                            next
                          end

              elsif value.is_a?(Hash)
                association = target_klass.reflect_on_association(key)

                if association.nil?
                  @issues << Issue.new(
                    code: :invalid_association,
                    detail: "#{key} is not a valid association on #{target_klass.name}",
                    path: [:sort, key],
                    meta: { field: key, class: target_klass.name }
                  )
                  next
                end

                unless schema_class.association_definitions[key]&.sortable?
                  @issues << Issue.new(
                    code: :association_not_sortable,
                    detail: "Association #{key} is not sortable",
                    path: [:sort, key],
                    meta: { association: key }
                  )
                  next
                end

                association_resource = schema_class.association_definitions[key]&.schema_class

                if association_resource.nil?
                  @issues << Issue.new(
                    code: :association_resource_not_found,
                    detail: "Cannot find resource for association #{key}",
                    path: [:sort, key],
                    meta: { association: key }
                  )
                  next
                end

                nested_query = Sorter.new(association.klass.all, association_resource, @issues)
                nested_orders, nested_joins = nested_query.send(:build_order_clauses, value, association.klass)
                orders.concat(nested_orders)

                joins << (nested_joins.any? ? { key => nested_joins } : key)
              else
                @issues << Issue.new(
                  code: :invalid_sort_value_type,
                  detail: "Sort value must be 'asc', 'desc', or Hash for associations",
                  path: [:sort, key],
                  meta: { field: key, value_type: value.class.name }
                )
              end
            end
          end
        end
      end
    end
  end
end
