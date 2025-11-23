# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      class ResponseGenerator
        class << self
          def resolve_resource_type_name(contract_class, schema_class)
            if TypeBuilder.sti_base_schema?(schema_class)
              TypeBuilder.build_sti_response_union_type(contract_class, schema_class)
            else
              root_key = schema_class.root_key.singular.to_sym
              resource_type_name = Descriptor.scoped_type_name(contract_class, nil)

              unless Descriptor.resolve_type(resource_type_name, contract_class: contract_class)
                register_resource_type(contract_class, schema_class, root_key)
              end

              resource_type_name
            end
          end

          def generate_single_response(definition, schema_class)
            root_key = schema_class.root_key.singular.to_sym
            contract_class = definition.contract_class
            resource_type_name = resolve_resource_type_name(contract_class, schema_class)

            definition.instance_variable_set(:@unwrapped_union, true)
            definition.instance_variable_set(:@unwrapped_union_discriminator, :ok)

            definition.param :ok, type: :boolean, required: true
            definition.param root_key, type: resource_type_name, required: false
            definition.param :meta, type: :object, required: false

            definition.param :issues, type: :array, of: :issue, required: false
          end

          def generate_collection_response(definition, schema_class)
            root_key_plural = schema_class.root_key.plural.to_sym
            contract_class = definition.contract_class
            resource_type_name = resolve_resource_type_name(contract_class, schema_class)

            definition.instance_variable_set(:@unwrapped_union, true)
            definition.instance_variable_set(:@unwrapped_union_discriminator, :ok)

            definition.param :ok, type: :boolean, required: true
            definition.param root_key_plural, type: :array, of: resource_type_name, required: false
            definition.param :meta, type: :object, required: false do
              param :pagination, type: :pagination, required: true
            end

            definition.param :issues, type: :array, of: :issue, required: false
          end

          private

          def register_resource_type(contract_class, schema_class, type_name)
            assoc_type_map = {}
            schema_class.association_definitions.each do |name, association_definition|
              assoc_type_map[name] = TypeBuilder.build_association_type(contract_class, association_definition)
            end

            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.enum

              enum_values = attribute_definition.enum
              Descriptor.register_enum(name, enum_values, scope: contract_class,
                                                          api_class: contract_class.api_class)
            end

            Descriptor.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              schema_class.attribute_definitions.each do |name, attribute_definition|
                enum_option = attribute_definition.enum ? { enum: name } : {}

                param name,
                      type: Generator.map_type(attribute_definition.type),
                      required: false,
                      description: attribute_definition.description,
                      example: attribute_definition.example,
                      format: attribute_definition.format,
                      deprecated: attribute_definition.deprecated,
                      **enum_option
              end

              schema_class.association_definitions.each do |name, association_definition|
                assoc_type = assoc_type_map[name]

                base_options = {
                  required: association_definition.always_included?,
                  nullable: association_definition.nullable?,
                  description: association_definition.description,
                  example: association_definition.example,
                  deprecated: association_definition.deprecated
                }

                if association_definition.singular?
                  param name, type: assoc_type || :object, **base_options
                elsif association_definition.collection?
                  if assoc_type
                    param name, type: :array, of: assoc_type, **base_options
                  else
                    param name, type: :array, **base_options
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
