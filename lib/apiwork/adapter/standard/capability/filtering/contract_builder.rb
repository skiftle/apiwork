# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class ContractBuilder < Adapter::Capability::Contract::Base
            TYPE_NAME = :filter
            UNFILTERABLE_TYPES = %i[unknown array object union].freeze

            def build
              return unless filterable?

              representation_class.attributes.each do |name, attribute|
                next unless attribute.filterable? && attribute.enum

                type_name = [name, TYPE_NAME].join('_').to_sym
                next if type?(type_name)

                scoped = scoped_enum_name(name)

                union(type_name) do |union|
                  union.variant do |element|
                    element.reference(scoped)
                  end
                  union.variant(partial: true) do |element|
                    element.object do |object|
                      object.reference(:eq, to: scoped)
                      object.array(:in) do |array|
                        array.reference(scoped)
                      end
                    end
                  end
                end
              end

              build_polymorphic_type_filters
              build_sti_type_filters

              attributes = representation_class.attributes.filter_map do |name, attribute|
                next unless attribute.filterable? && UNFILTERABLE_TYPES.exclude?(attribute.type)

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

                contract = contract_for(representation)
                next unless contract

                alias_name = representation.root_key.singular.to_sym
                import(contract, as: alias_name)

                filter_type = [alias_name, TYPE_NAME].join('_').to_sym
                next unless type?(filter_type)

                [name, filter_type]
              end

              object(TYPE_NAME) do |object|
                object.array?(Constants::AND) do |element|
                  element.reference(TYPE_NAME)
                end
                object.array?(Constants::OR) do |element|
                  element.reference(TYPE_NAME)
                end
                object.reference?(Constants::NOT, to: TYPE_NAME)

                attributes.each do |name, type, filter_type, shorthand|
                  if shorthand
                    object.union?(name) do |union|
                      union.variant do |element|
                        element.of(type)
                      end
                      union.variant do |element|
                        element.reference(filter_type)
                      end
                    end
                  else
                    object.reference?(name, to: filter_type)
                  end
                end

                associations.each do |name, filter_type|
                  object.reference?(name, to: filter_type)
                end
              end

              return unless type?(TYPE_NAME)

              action(:index) do |act|
                act.request do |request|
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

            def build_polymorphic_type_filters
              representation_class.attributes.each do |name, attribute|
                next unless attribute.filterable?

                association = representation_class.polymorphic_association_for_type_column(name)
                next unless association

                type_name = [name, TYPE_NAME].join('_').to_sym
                next if type?(type_name)

                allowed_values = association.polymorphic.map(&:polymorphic_name)

                enum name, values: allowed_values

                scoped = scoped_enum_name(name)

                union(type_name) do |union|
                  union.variant do |element|
                    element.reference(scoped)
                  end
                  union.variant(partial: true) do |element|
                    element.object do |object|
                      object.reference(:eq, to: scoped)
                      object.array(:in) do |array|
                        array.reference(scoped)
                      end
                    end
                  end
                end
              end
            end

            def build_sti_type_filters
              return if representation_class.subclass?

              representation_class.attributes.each do |name, attribute|
                next unless attribute.filterable?

                inheritance = representation_class.inheritance_for_column(name)
                next unless inheritance

                type_name = [name, TYPE_NAME].join('_').to_sym
                next if type?(type_name)

                allowed_values = inheritance.subclasses.map(&:sti_name)

                enum name, values: allowed_values

                scoped = scoped_enum_name(name)

                union(type_name) do |union|
                  union.variant do |element|
                    element.reference(scoped)
                  end
                  union.variant(partial: true) do |element|
                    element.object do |object|
                      object.reference(:eq, to: scoped)
                      object.array(:in) do |array|
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
              representation_class.inheritance_for_column(attribute.name).present?
            end

            def filter_type_for(attribute)
              custom_type = [attribute.name, TYPE_NAME].join('_').to_sym
              return custom_type if attribute.enum
              return custom_type if polymorphic_type_column?(attribute)
              return custom_type if sti_type_column?(attribute)

              type = case attribute.type
                     when :string, :binary then :string_filter
                     when :date then :date_filter
                     when :datetime then :datetime_filter
                     when :time then :time_filter
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
              representation_class.attributes.values.any? { |attribute| attribute.filterable? && UNFILTERABLE_TYPES.exclude?(attribute.type) } ||
                representation_class.associations.values.any?(&:filterable?)
            end
          end
        end
      end
    end
  end
end
