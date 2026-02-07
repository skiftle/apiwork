# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Resource
        class Default < Base
          class ContractBuilder < Adapter::Builder::Contract::Base
            def build
              build_enums
              resource_type_name
            end

            def resource_type_name
              if sti_base_representation?
                build_sti_response_union_type
              else
                register_type(representation_class.root_key.singular.to_sym) unless type?(scoped_type_name(nil))

                scoped_type_name(nil)
              end
            end

            def import_association_contract(association_representation, visited)
              return nil if visited.include?(association_representation)

              association_contract = contract_for(association_representation)
              return nil unless association_contract

              alias_name = association_representation.root_key.singular.to_sym
              import(association_contract, as: alias_name)
              alias_name
            end

            private

            def build_enums
              representation_class.attributes.each do |name, attribute|
                next unless attribute.enum&.any?

                enum(name, values: attribute.enum)
              end
            end

            def register_type(type_name)
              association_type_map = {}
              representation_class.associations.each do |name, association|
                association_type_map[name] = build_association_type(association)
              end

              object(type_name, representation_class: representation_class) do |object|
                if representation_class.subclass?
                  discriminator_name = representation_class.superclass.inheritance.column
                  object.literal(discriminator_name, value: representation_class.sti_name)
                end

                representation_class.attributes.each do |name, attribute|
                  enum_option = attribute.enum ? { enum: name } : {}
                  of_option = attribute.of ? { of: attribute.of } : {}

                  param_options = {
                    deprecated: attribute.deprecated?,
                    description: attribute.description,
                    example: attribute.example,
                    format: attribute.format,
                    nullable: attribute.nullable?,
                    type: attribute.type,
                    **enum_option,
                    **of_option,
                  }

                  element = attribute.element
                  if element
                    if element.type == :array
                      param_options[:of] = { type: element.of_type }
                      param_options[:shape] = element.shape
                    else
                      param_options[:shape] = element.shape
                      param_options[:discriminator] = element.discriminator if element.discriminator
                    end
                  end

                  object.param(name, **param_options)
                end

                representation_class.associations.each do |name, association|
                  association_type = association_type_map[name]

                  base_options = {
                    deprecated: association.deprecated?,
                    description: association.description,
                    example: association.example,
                    nullable: association.nullable?,
                    optional: association.include != :always,
                  }

                  if association.singular?
                    object.param(name, type: association_type || :object, **base_options)
                  elsif association.collection?
                    if association_type
                      object.param(name, type: :array, **base_options) do |param|
                        param.of(association_type)
                      end
                    else
                      object.param(name, type: :array, **base_options)
                    end
                  end
                end
              end
            end

            def sti_base_representation?
              inheritance = representation_class.inheritance
              inheritance&.subclasses&.any? && inheritance.base_class == representation_class
            end

            def build_sti_union(union_type_name:, visited: Set.new)
              representation_inheritance = representation_class.inheritance
              return nil unless representation_inheritance.subclasses.any?

              discriminator_name = representation_inheritance.column

              variant_types = representation_inheritance.subclasses.filter_map do |subclass|
                variant_type = yield(subclass)
                { tag: subclass.sti_name, type: variant_type } if variant_type
              end

              union(union_type_name, discriminator: discriminator_name) do |union|
                variant_types.each do |variant_type|
                  union.variant(tag: variant_type[:tag]) do |variant|
                    variant.reference(variant_type[:type])
                  end
                end
              end

              union_type_name
            end

            def build_sti_response_union_type(visited: Set.new)
              union_type_name = representation_class.root_key.singular.to_sym

              build_sti_union(union_type_name:, visited:) do |variant_representation_class|
                variant_contract = contract_for(variant_representation_class)
                next nil unless variant_contract

                alias_name = variant_representation_class.root_key.singular.to_sym
                import(variant_contract, as: alias_name)

                alias_name
              end
            end

            def build_association_type(association, visited: Set.new)
              return build_polymorphic_association_type(association, visited:) if association.polymorphic?

              association_info = resolve_association(association)
              return nil unless association_info

              representation_class = association_info[:representation_class]

              return import_association_contract(representation_class, visited) if association_info[:sti]
              return nil if visited.include?(representation_class)

              association_contract = contract_for(representation_class)
              return nil unless association_contract

              type_name = representation_class.root_key.singular.to_sym
              import(association_contract, as: type_name)
              type_name
            end

            def build_polymorphic_association_type(association, visited: Set.new)
              polymorphic = association.polymorphic
              return nil unless polymorphic.any?

              union_type_name = association.name

              existing_type = type?(union_type_name)
              return union_type_name if existing_type

              union(union_type_name, discriminator: association.discriminator) do |union|
                polymorphic.each do |poly_representation_class|
                  tag = poly_representation_class.polymorphic_name
                  alias_name = import_association_contract(poly_representation_class, visited)
                  next unless alias_name

                  union.variant(tag:) do |variant|
                    variant.reference(alias_name)
                  end
                end
              end

              union_type_name
            end

            def resolve_association(association)
              return nil if association.polymorphic?

              representation_class = association.representation_class
              return nil unless representation_class

              { representation_class:, sti: representation_class.inheritance&.subclasses&.any? }
            end
          end
        end
      end
    end
  end
end
