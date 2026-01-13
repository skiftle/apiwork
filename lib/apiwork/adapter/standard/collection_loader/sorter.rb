# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
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
                :sort_params_invalid,
                'Invalid sort params',
                meta: { type: params.class.name },
                path: [:sort],
              )
              return @relation
            end

            orders, joins = build_order_clauses(params, schema_class.model_class)
            scope = @relation.joins(joins).order(orders)
            scope = scope.distinct if joins.present?
            scope
          end

          def build_order_clauses(params, target_klass = schema_class.model_class)
            params.each_with_object([[], []]) do |(key, value), (orders, joins)|
              key = key.to_sym

              if value.is_a?(String) || value.is_a?(Symbol)
                attribute = schema_class.attributes[key]
                unless attribute&.sortable?
                  available = schema_class.attributes
                    .values
                    .select(&:sortable?)
                    .map(&:name)

                  @issues << Issue.new(
                    :field_not_sortable,
                    'Not sortable',
                    meta: { available:, field: key },
                    path: [:sort, key],
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
                              :sort_direction_invalid,
                              'Invalid direction',
                              meta: {
                                direction:,
                                allowed: %i[asc desc],
                                field: key,
                              },
                              path: [:sort, key],
                            )
                            next
                          end

              elsif value.is_a?(Hash)
                association = target_klass.reflect_on_association(key)

                if association.nil?
                  @issues << Issue.new(
                    :association_invalid,
                    'Invalid association',
                    meta: { field: key },
                    path: [:sort, key],
                  )
                  next
                end

                unless schema_class.associations[key]&.sortable?
                  @issues << Issue.new(
                    :association_not_sortable,
                    'Not sortable',
                    meta: { association: key },
                    path: [:sort, key],
                  )
                  next
                end

                association_resource = schema_class.associations[key]&.schema_class

                if association_resource.nil?
                  @issues << Issue.new(
                    :association_schema_missing,
                    'Association schema missing',
                    meta: { association: key },
                    path: [:sort, key],
                  )
                  next
                end

                nested_query = Sorter.new(association.klass.all, association_resource, @issues)
                nested_orders, nested_joins = nested_query.build_order_clauses(value, association.klass)
                orders.concat(nested_orders)

                joins << (nested_joins.any? ? { key => nested_joins } : key)
              else
                @issues << Issue.new(
                  :sort_value_invalid,
                  'Invalid sort value',
                  meta: { field: key, type: value.class.name },
                  path: [:sort, key],
                )
              end
            end
          end
        end
      end
    end
  end
end
