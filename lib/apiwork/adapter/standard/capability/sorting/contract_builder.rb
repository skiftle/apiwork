# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class ContractBuilder < Adapter::Capability::Contract::Base
            TYPE_NAME = :sort

            def build
              return unless build_type

              action(:index) do |action|
                action.request do |request|
                  request.query do |query|
                    query.union?(TYPE_NAME) do |union|
                      union.variant do |element|
                        element.reference(TYPE_NAME)
                      end
                      union.variant do |element|
                        element.array do |array|
                          array.reference(TYPE_NAME)
                        end
                      end
                    end
                  end
                end
              end
            end

            private

            def build_type
              return unless sortable_content?

              object(TYPE_NAME) do |object|
                collect_attribute_sorts.each do |name|
                  object.reference?(name, to: :sort_direction)
                end

                collect_association_sorts.each do |sort_config|
                  object.reference?(sort_config[:name], to: sort_config[:type])
                end
              end
            end

            def collect_attribute_sorts
              representation_class.attributes.filter_map do |name, attribute|
                name if attribute.sortable?
              end
            end

            def collect_association_sorts
              representation_class.associations.filter_map do |name, association|
                next unless association.sortable?
                next if association.polymorphic?

                representation = association.representation_class
                next unless representation

                contract = find_contract_for_representation(representation)
                next unless contract

                alias_name = representation.root_key.singular.to_sym
                import(contract, as: alias_name)

                nested_type = :"#{alias_name}_#{TYPE_NAME}"
                next unless type?(nested_type)

                { name:, type: nested_type }
              end
            end

            def sortable_content?
              representation_class.attributes.values.any?(&:sortable?) ||
                representation_class.associations.values.any?(&:sortable?)
            end
          end
        end
      end
    end
  end
end
