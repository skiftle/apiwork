# frozen_string_literal: true

module Apiwork
  module Adapter
    module Representation
      class Default < Base
        module Types
          class Resources
            attr_reader :registrar,
                        :schema_class

            class << self
              def build(registrar, schema_class)
                new(registrar, schema_class).build
              end
            end

            def initialize(registrar, schema_class)
              @registrar = registrar
              @schema_class = schema_class
            end

            def build
              build_enums
              build_resource_type
            end

            def resource_type_name
              if sti_base_schema?
                build_sti_response_union_type
              else
                register_resource_type(schema_class.root_key.singular.to_sym) unless registrar.type?(registrar.scoped_type_name(nil))

                registrar.scoped_type_name(nil)
              end
            end

            private

            def build_enums
              schema_class.attributes.each do |name, attribute|
                next unless attribute.enum&.any?

                registrar.enum(name, values: attribute.enum)
              end
            end

            def build_resource_type
              resource_type_name
            end

            def register_resource_type(type_name)
              association_type_map = {}
              schema_class.associations.each do |name, association|
                association_type_map[name] = build_association_type(association)
              end

              local_schema_class = schema_class
              registrar.object(type_name, schema_class: local_schema_class) do
                local_schema_class.attributes.each do |name, attribute|
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

                local_schema_class.associations.each do |name, association|
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

            def sti_base_schema?
              return false unless schema_class.discriminated?

              schema_class.union&.variants&.any?
            end

            def build_sti_union(union_type_name:, visited: Set.new)
              schema_union = schema_class.union
              return nil unless schema_union&.variants&.any?

              discriminator_name = schema_union.discriminator

              variant_types = schema_union.variants.filter_map do |tag, variant|
                variant_schema_class = variant.schema_class
                variant_type = yield(variant_schema_class, tag, visited)
                { tag: tag.to_s, type: variant_type } if variant_type
              end

              registrar.union(union_type_name, discriminator: discriminator_name) do
                variant_types.each do |variant_type|
                  variant tag: variant_type[:tag] do
                    reference variant_type[:type]
                  end
                end
              end

              union_type_name
            end

            def build_sti_response_union_type(visited: Set.new)
              union_type_name = schema_class.root_key.singular.to_sym
              discriminator_name = schema_class.union.discriminator
              builder = self

              build_sti_union(union_type_name:, visited:) do |variant_schema_class, tag, visit_set|
                variant_type_name = variant_schema_class.root_key.singular.to_sym

                unless registrar.api_registrar.type?(variant_type_name)
                  association_type_map = {}
                  variant_schema_class.associations.each do |name, association|
                    association_type_map[name] = builder.send(:build_association_type, association, visited: visit_set)
                  end

                  registrar.api_registrar.object(variant_type_name, schema_class: variant_schema_class) do
                    literal discriminator_name, value: tag.to_s

                    variant_schema_class.attributes.each do |name, attribute|
                      enum_option = attribute.enum ? { enum: name } : {}
                      param name,
                            deprecated: attribute.deprecated,
                            description: attribute.description,
                            example: attribute.example,
                            format: attribute.format,
                            nullable: attribute.nullable?,
                            type: attribute.type,
                            **enum_option
                    end

                    variant_schema_class.associations.each do |name, association|
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

                variant_type_name
              end
            end

            def build_association_type(association, visited: Set.new)
              return build_polymorphic_association_type(association, visited:) if association.polymorphic?

              association_resource = resolve_association_resource(association)
              return nil unless association_resource

              association_schema = association_resource[:schema_class]

              return build_sti_association_type(association, association_schema, visited:) if association_resource[:sti]
              return nil if visited.include?(association_schema)

              association_contract = registrar.find_contract_for_schema(association_schema)
              return nil unless association_contract

              alias_name = association_schema.root_key.singular.to_sym
              registrar.import(association_contract, as: alias_name)
              alias_name
            end

            def build_polymorphic_association_type(association, visited: Set.new)
              polymorphic = association.polymorphic
              return nil unless polymorphic&.any?

              union_type_name = association.name

              existing_type = registrar.type?(union_type_name)
              return union_type_name if existing_type

              builder = self
              discriminator = association.discriminator
              association_local = association

              registrar.union(union_type_name, discriminator:) do
                association_local.polymorphic.each_key do |tag|
                  association_schema_class = association_local.resolve_polymorphic_schema(tag)
                  next unless association_schema_class

                  alias_name = builder.import_association_contract(association_schema_class, visited)
                  next unless alias_name

                  variant tag: tag.to_s do
                    reference alias_name
                  end
                end
              end

              union_type_name
            end

            def build_sti_association_type(association, association_schema_class, visited: Set.new)
              alias_name = import_association_contract(association_schema_class, visited)
              return nil unless alias_name

              alias_name
            end

            def resolve_association_resource(association)
              return nil if association.polymorphic?

              resolved_schema = resolve_schema_from_association(association)
              return nil unless resolved_schema

              { schema_class: resolved_schema, sti: resolved_schema.discriminated? }
            end

            def resolve_schema_from_association(association)
              return association.schema_class if association.schema_class

              model_class = association.model_class
              return nil unless model_class

              reflection = model_class.reflect_on_association(association.name)
              return nil unless reflection

              infer_association_schema(reflection)
            end

            def infer_association_schema(reflection)
              return nil if reflection.polymorphic?

              namespace = schema_class.name.deconstantize
              "#{namespace}::#{reflection.klass.name.demodulize}Schema".safe_constantize
            end

            def import_association_contract(association_schema, visited)
              return nil if visited.include?(association_schema)

              association_contract = registrar.find_contract_for_schema(association_schema)

              unless association_contract
                contract_name = association_schema.name.sub(/Schema$/, 'Contract')
                association_contract = begin
                  contract_name.constantize
                rescue NameError
                  nil
                end
              end

              return nil unless association_contract

              alias_name = association_schema.root_key.singular.to_sym
              registrar.import(association_contract, as: alias_name)
              alias_name
            end
          end
        end
      end
    end
  end
end
