# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
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
                code: :sort_params_invalid,
                detail: 'Invalid sort params',
                path: [:sort],
                meta: { type: params.class.name },
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
                    detail: 'Not sortable',
                    path: [:sort, key],
                    meta: { available: available, field: key },
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
                              code: :sort_direction_invalid,
                              detail: 'Invalid direction',
                              path: [:sort, key],
                              meta: {
                                allowed: %i[asc desc],
                                direction: direction,
                                field: key,
                              },
                            )
                            next
                          end

              elsif value.is_a?(Hash)
                association = target_klass.reflect_on_association(key)

                if association.nil?
                  @issues << Issue.new(
                    code: :association_invalid,
                    detail: 'Invalid association',
                    path: [:sort, key],
                    meta: { field: key },
                  )
                  next
                end

                unless schema_class.association_definitions[key]&.sortable?
                  @issues << Issue.new(
                    code: :association_not_sortable,
                    detail: 'Not sortable',
                    path: [:sort, key],
                    meta: { association: key },
                  )
                  next
                end

                association_resource = schema_class.association_definitions[key]&.schema_class

                if association_resource.nil?
                  @issues << Issue.new(
                    code: :association_schema_missing,
                    detail: 'Association schema missing',
                    path: [:sort, key],
                    meta: { association: key },
                  )
                  next
                end

                nested_query = Sorter.new(association.klass.all, association_resource, @issues)
                nested_orders, nested_joins = nested_query.send(:build_order_clauses, value, association.klass)
                orders.concat(nested_orders)

                joins << (nested_joins.any? ? { key => nested_joins } : key)
              else
                @issues << Issue.new(
                  code: :sort_value_invalid,
                  detail: 'Invalid sort value',
                  path: [:sort, key],
                  meta: { field: key, type: value.class.name },
                )
              end
            end
          end
        end
      end
    end
  end
end
