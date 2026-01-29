# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Resource
        class Default < Base
          class Types
            attr_reader :contract_class,
                        :representation_class

            class << self
              def build(contract_class, representation_class)
                new(contract_class, representation_class).build
              end
            end

            def initialize(contract_class, representation_class)
              @contract_class = contract_class
              @representation_class = representation_class
            end

            def build
              build_enums
              build_resource_type
            end

            def resource_type_name
              if sti_base_representation?
                build_sti_response_union_type
              else
                unless contract_class.type?(contract_class.scoped_type_name(nil))
                  register_resource_type(representation_class.root_key.singular.to_sym)
                end

                contract_class.scoped_type_name(nil)
              end
            end

            def import_association_contract(association_representation, visited)
              return nil if visited.include?(association_representation)

              association_contract = contract_class.find_contract_for_representation(association_representation)
              return nil unless association_contract

              alias_name = association_representation.root_key.singular.to_sym
              contract_class.import(association_contract, as: alias_name)
              alias_name
            end

            private

            def build_enums
              representation_class.attributes.each do |name, attribute|
                next unless attribute.enum&.any?

                contract_class.enum(name, values: attribute.enum)
              end
            end

            def build_resource_type
              resource_type_name
            end

            def register_resource_type(type_name)
              association_type_map = {}
              representation_class.associations.each do |name, association|
                association_type_map[name] = build_association_type(association)
              end

              local_representation_class = representation_class
              contract_class.object(type_name, representation_class: local_representation_class) do
                if local_representation_class.variant?
                  discriminator_name = local_representation_class.superclass.union.discriminator
                  literal discriminator_name, value: local_representation_class.tag.to_s
                end

                local_representation_class.attributes.each do |name, attribute|
                  enum_option = attribute.enum ? { enum: name } : {}
                  of_option = attribute.of ? { of: attribute.of } : {}

                  param_options = {
                    deprecated: attribute.deprecated,
                    description: attribute.description,
                    example: attribute.example,
                    format: attribute.format,
                    nullable: attribute.nullable?,
                    type: attribute.type,
                    **enum_option,
                    **of_option,
                  }

                  if attribute.element
                    element = attribute.element

                    if element.type == :array
                      param_options[:of] = { type: element.of_type }
                      param_options[:shape] = element.shape
                    else
                      param_options[:shape] = element.shape
                      param_options[:discriminator] = element.discriminator if element.discriminator
                    end
                  end

                  param name, **param_options
                end

                local_representation_class.associations.each do |name, association|
                  association_type = association_type_map[name]

                  base_options = {
                    deprecated: association.deprecated,
                    description: association.description,
                    example: association.example,
                    nullable: association.nullable?,
                    optional: association.include != :always,
                  }

                  if association.singular?
                    param name, type: association_type || :object, **base_options
                  elsif association.collection?
                    if association_type
                      param name, type: :array, **base_options do
                        of association_type
                      end
                    else
                      param name, type: :array, **base_options
                    end
                  end
                end
              end
            end

            def sti_base_representation?
              return false unless representation_class.discriminated?

              representation_class.union&.variants&.any?
            end

            def build_sti_union(union_type_name:, visited: Set.new)
              representation_union = representation_class.union
              return nil unless representation_union&.variants&.any?

              discriminator_name = representation_union.discriminator

              variant_types = representation_union.variants.filter_map do |tag, variant|
                variant_representation_class = variant.representation_class
                variant_type = yield(variant_representation_class, tag, visited)
                { tag: tag.to_s, type: variant_type } if variant_type
              end

              contract_class.union(union_type_name, discriminator: discriminator_name) do
                variant_types.each do |variant_type|
                  variant tag: variant_type[:tag] do
                    reference variant_type[:type]
                  end
                end
              end

              union_type_name
            end

            def build_sti_response_union_type(visited: Set.new)
              union_type_name = representation_class.root_key.singular.to_sym

              build_sti_union(union_type_name:, visited:) do |variant_representation_class, _tag, _visit_set|
                variant_contract = contract_class.find_contract_for_representation(variant_representation_class)
                next nil unless variant_contract

                alias_name = variant_representation_class.root_key.singular.to_sym
                contract_class.import(variant_contract, as: alias_name)

                alias_name
              end
            end

            def build_association_type(association, visited: Set.new)
              return build_polymorphic_association_type(association, visited:) if association.polymorphic?

              association_resource = resolve_association_resource(association)
              return nil unless association_resource

              association_representation = association_resource[:representation_class]

              return build_sti_association_type(association, association_representation, visited:) if association_resource[:sti]
              return nil if visited.include?(association_representation)

              association_contract = contract_class.find_contract_for_representation(association_representation)
              return nil unless association_contract

              alias_name = association_representation.root_key.singular.to_sym
              contract_class.import(association_contract, as: alias_name)
              alias_name
            end

            def build_polymorphic_association_type(association, visited: Set.new)
              polymorphic = association.polymorphic
              return nil unless polymorphic&.any?

              union_type_name = association.name

              existing_type = contract_class.type?(union_type_name)
              return union_type_name if existing_type

              builder = self
              discriminator = association.discriminator

              contract_class.union(union_type_name, discriminator:) do
                polymorphic.each do |representation_class|
                  tag = representation_class.type_name || representation_class.model_class.polymorphic_name
                  alias_name = builder.import_association_contract(representation_class, visited)
                  next unless alias_name

                  variant tag: tag.to_s do
                    reference alias_name
                  end
                end
              end

              union_type_name
            end

            def build_sti_association_type(association, association_representation_class, visited: Set.new)
              alias_name = import_association_contract(association_representation_class, visited)
              return nil unless alias_name

              alias_name
            end

            def resolve_association_resource(association)
              return nil if association.polymorphic?

              resolved_representation = resolve_representation_from_association(association)
              return nil unless resolved_representation

              { representation_class: resolved_representation, sti: resolved_representation.discriminated? }
            end

            def resolve_representation_from_association(association)
              return association.representation_class if association.representation_class

              model_class = association.model_class
              return nil unless model_class

              reflection = model_class.reflect_on_association(association.name)
              return nil unless reflection

              infer_association_representation(reflection)
            end

            def infer_association_representation(reflection)
              return nil if reflection.polymorphic?

              namespace = representation_class.name.deconstantize
              "#{namespace}::#{reflection.klass.name.demodulize}Representation".safe_constantize
            end
          end
        end
      end
    end
  end
end
