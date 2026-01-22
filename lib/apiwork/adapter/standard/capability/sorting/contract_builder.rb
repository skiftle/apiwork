# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class ContractBuilder < Adapter::Capability::ContractBuilder::Base
            def build
              build_sort_type
              return unless type?(:sort)

              action :index do
                request do
                  query do
                    union? :sort do
                      variant { reference :sort }
                      variant { array { reference :sort } }
                    end
                  end
                end
              end
            end

            private

            def build_sort_type
              return unless sortable_content?

              attribute_sorts = collect_attribute_sorts
              association_sorts = collect_association_sorts

              object :sort do
                attribute_sorts.each do |name|
                  reference name, optional: true, to: :sort_direction
                end

                association_sorts.each do |sort|
                  reference sort[:name], optional: true, to: sort[:type]
                end
              end
            end

            def collect_attribute_sorts
              schema_class.attributes.filter_map do |name, attribute|
                name if attribute.sortable?
              end
            end

            def collect_association_sorts
              schema_class.associations.filter_map do |name, association|
                next unless association.sortable?

                alias_name = ensure_association_types(association)
                next unless alias_name

                nested_type = :"#{alias_name}_sort"
                next unless type?(nested_type)

                { name:, type: nested_type }
              end
            end

            def sortable_content?
              schema_class.attributes.values.any?(&:sortable?) ||
                schema_class.associations.values.any?(&:sortable?)
            end
          end
        end
      end
    end
  end
end
