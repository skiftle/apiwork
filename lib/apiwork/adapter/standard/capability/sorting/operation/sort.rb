# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Operation < Adapter::Capability::Operation::Base
            class Sort
              attr_reader :representation_class

              class << self
                def apply(relation, representation_class, params)
                  sorter = new(relation, representation_class)
                  result = sorter.sort(params)

                  includes = IncludesResolver.new(representation_class).resolve_params(params)
                  { includes:, data: result }
                end
              end

              def initialize(relation, representation_class)
                @relation = relation
                @representation_class = representation_class
              end

              def sort(params)
                return @relation if params.blank?

                params = params.reduce({}) { |acc, hash| acc.merge(hash) } if params.is_a?(Array)
                return @relation unless params.is_a?(Hash)

                orders, joins = build_order_clauses(params, representation_class.model_class)
                scope = @relation.joins(joins).order(orders)
                scope = scope.distinct if joins.present?
                scope
              end

              def build_order_clauses(params, target_klass = representation_class.model_class)
                params.each_with_object([[], []]) do |(key, value), (orders, joins)|
                  key = key.to_sym

                  if value.is_a?(String) || value.is_a?(Symbol)
                    attribute = representation_class.attributes[key]
                    next unless attribute&.sortable?

                    column = target_klass.arel_table[key]
                    direction = value.to_sym

                    case direction
                    when :asc then orders << column.asc
                    when :desc then orders << column.desc
                    end

                  elsif value.is_a?(Hash)
                    association = target_klass.reflect_on_association(key)
                    next unless association
                    next unless representation_class.associations[key]&.sortable?

                    association_resource = representation_class.associations[key]&.representation_class
                    next unless association_resource

                    nested_query = Sort.new(association.klass.all, association_resource)
                    nested_orders, nested_joins = nested_query.build_order_clauses(value, association.klass)
                    orders.concat(nested_orders)

                    joins << (nested_joins.any? ? { key => nested_joins } : key)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
