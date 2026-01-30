# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class ContractBuilder < Adapter::Capability::Contract::Base
            TYPE_NAME = :filter

            def build
              return unless filterable?

              representation_class.attributes.each do |name, attribute|
                next unless attribute.filterable? && attribute.enum
                next if type?([name, TYPE_NAME].join('_').to_sym)

                scoped = scoped_enum_name(name)

                union([name, TYPE_NAME].join('_').to_sym) do |u|
                  u.variant do |element|
                    element.reference(scoped)
                  end
                  u.variant(partial: true) do |element|
                    element.object do |obj|
                      obj.reference(:eq, to: scoped)
                      obj.array(:in) do |array|
                        array.reference(scoped)
                      end
                    end
                  end
                end
              end

              build_polymorphic_type_filters
              build_sti_type_filters

              attributes = representation_class.attributes.filter_map do |name, attribute|
                next unless attribute.filterable? && attribute.type != :unknown

                filter_type = filter_type_for(attribute)
                has_custom_filter = attribute.enum || polymorphic_type_column?(attribute) || sti_type_column?(attribute)
                shorthand = !has_custom_filter && !%i[object array union].include?(attribute.type)
                [name, attribute.type, filter_type, shorthand]
              end

              associations = representation_class.associations.filter_map do |name, association|
                next unless association.filterable?
                next if association.polymorphic?

                representation = association.representation_class
                next unless representation

                contract = find_contract_for_representation(representation)
                next unless contract

                alias_name = representation.root_key.singular.to_sym
                import(contract, as: alias_name)

                filter_type = [alias_name, TYPE_NAME].join('_').to_sym
                next unless type?(filter_type)

                [name, filter_type]
              end

              object(TYPE_NAME) do |obj|
                obj.array?(Constants::AND) do |element|
                  element.reference(TYPE_NAME)
                end
                obj.array?(Constants::OR) do |element|
                  element.reference(TYPE_NAME)
                end
                obj.reference?(Constants::NOT, to: TYPE_NAME)

                attributes.each do |name, type, filter_type, shorthand|
                  if shorthand
                    obj.union?(name) do |u|
                      u.variant do |element|
                        element.of(type)
                      end
                      u.variant do |element|
                        element.reference(filter_type)
                      end
                    end
                  else
                    obj.reference?(name, to: filter_type)
                  end
                end

                associations.each do |name, filter_type|
                  obj.reference?(name, to: filter_type)
                end
              end

              return unless type?(TYPE_NAME)

              action(:index) do |act|
                act.request do |request|
                  request.query do |query|
                    query.union?(TYPE_NAME) do |u|
                      u.variant do |element|
                        element.reference(TYPE_NAME)
                      end
                      u.variant do |element|
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

            def build_polymorphic_type_filters
              representation_class.attributes.each do |name, attribute|
                next unless attribute.filterable?

                association = representation_class.polymorphic_association_for_type_column(name)
                next unless association
                next if type?([name, TYPE_NAME].join('_').to_sym)

                allowed_values = association.polymorphic.map do |rep_class|
                  (rep_class.type_name || rep_class.model_class.polymorphic_name).to_s
                end

                enum name, values: allowed_values

                scoped = scoped_enum_name(name)

                union([name, TYPE_NAME].join('_').to_sym) do |u|
                  u.variant do |element|
                    element.reference(scoped)
                  end
                  u.variant(partial: true) do |element|
                    element.object do |obj|
                      obj.reference(:eq, to: scoped)
                      obj.array(:in) do |array|
                        array.reference(scoped)
                      end
                    end
                  end
                end
              end
            end

            def build_sti_type_filters
              representation_class.attributes.each do |name, attribute|
                next unless attribute.filterable?

                sti_union = representation_class.sti_union_for_type_column(name)
                next unless sti_union
                next if type?([name, TYPE_NAME].join('_').to_sym)

                allowed_values = sti_union.variants.values.map { |variant_data| variant_data.tag.to_s }

                enum name, values: allowed_values

                scoped = scoped_enum_name(name)

                union([name, TYPE_NAME].join('_').to_sym) do |u|
                  u.variant do |element|
                    element.reference(scoped)
                  end
                  u.variant(partial: true) do |element|
                    element.object do |obj|
                      obj.reference(:eq, to: scoped)
                      obj.array(:in) do |array|
                        array.reference(scoped)
                      end
                    end
                  end
                end
              end
            end

            def polymorphic_type_column?(attribute)
              representation_class.polymorphic_association_for_type_column(attribute.name).present?
            end

            def sti_type_column?(attribute)
              representation_class.sti_union_for_type_column(attribute.name).present?
            end

            def filter_type_for(attribute)
              custom_type = [attribute.name, TYPE_NAME].join('_').to_sym
              return custom_type if attribute.enum
              return custom_type if polymorphic_type_column?(attribute)
              return custom_type if sti_type_column?(attribute)

              type = case attribute.type
                     when :string then :string_filter
                     when :date then :date_filter
                     when :datetime then :datetime_filter
                     when :integer then :integer_filter
                     when :decimal then :decimal_filter
                     when :number then :number_filter
                     when :uuid then :uuid_filter
                     when :boolean then :boolean_filter
                     else :string_filter
                     end

              attribute.nullable? ? [:nullable, type].join('_').to_sym : type
            end

            def filterable?
              representation_class.attributes.values.any? { |a| a.filterable? && a.type != :unknown } ||
                representation_class.associations.values.any?(&:filterable?)
            end
          end
        end
      end
    end
  end
end
