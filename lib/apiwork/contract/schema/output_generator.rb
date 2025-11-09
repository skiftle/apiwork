# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Generates output schemas for CRUD actions
      # Handles single resource and collection responses with unwrapped discriminated unions
      class OutputGenerator
        class << self
          # Generate output for single resource actions (show, create, update)
          # Returns unwrapped discriminated union with ok field
          def generate_single_output(definition, schema_class)
            root_key = schema_class.root_key.singular.to_sym
            contract_class = definition.contract_class

            # Register the resource type with Descriptors::Registry
            # Use nil for registration - Descriptors::Registry will use just the prefix (e.g., "locale", "post")
            # Get the qualified name for reference
            resource_type_name = Descriptors::Registry.qualified_name(contract_class, nil)

            # Check if already registered
            unless Descriptors::Registry.resolve(resource_type_name, contract_class: contract_class)
              register_resource_type(contract_class, schema_class)
            end

            # Output is a discriminated union based on 'ok' field (literal values)
            # The union is "unwrapped" - fields are at top level, not under a wrapper key
            # Variant 1: ok: true (literal) with resource and optional meta
            # Variant 2: ok: false (literal) with errors array

            # Mark this definition as an unwrapped union for special serialization
            definition.instance_variable_set(:@unwrapped_union, true)
            definition.instance_variable_set(:@unwrapped_union_discriminator, :ok)

            # Define all possible fields from both variants
            # Success fields (ok: true variant)
            definition.param :ok, type: :boolean, required: true
            definition.param root_key, type: resource_type_name, required: false
            definition.param :meta, type: :object, required: false

            # Error fields (ok: false variant)
            definition.param :errors, type: :array, of: :error, required: false
          end

          # Generate output for collection actions (index)
          # Returns unwrapped discriminated union with ok field and pagination
          def generate_collection_output(definition, schema_class)
            root_key_singular = schema_class.root_key.singular.to_sym
            root_key_plural = schema_class.root_key.plural.to_sym
            contract_class = definition.contract_class

            # Register the resource type with Descriptors::Registry (same as single output)
            # Use nil for registration - Descriptors::Registry will use just the prefix
            # Get the qualified name for reference
            resource_type_name = Descriptors::Registry.qualified_name(contract_class, nil)

            # Check if already registered
            unless Descriptors::Registry.resolve(resource_type_name, contract_class: contract_class)
              register_resource_type(contract_class, schema_class)
            end

            # Output is a discriminated union based on 'ok' field (literal values)
            # The union is "unwrapped" - fields are at top level, not under a wrapper key
            # Variant 1: ok: true (literal) with resources array and meta with pagination
            # Variant 2: ok: false (literal) with errors array

            # Mark this definition as an unwrapped union for special serialization
            definition.instance_variable_set(:@unwrapped_union, true)
            definition.instance_variable_set(:@unwrapped_union_discriminator, :ok)

            # Define all possible fields from both variants
            # Success fields (ok: true variant)
            definition.param :ok, type: :boolean, required: true
            definition.param root_key_plural, type: :array, of: resource_type_name, required: false
            definition.param :meta, type: :object, required: false do
              param :page, type: :page, required: true
            end

            # Error fields (ok: false variant)
            definition.param :errors, type: :array, of: :error, required: false
          end

          private

          # Register resource type with all attributes and associations
          def register_resource_type(contract_class, schema_class)
            # PRE-REGISTER: Register all association types BEFORE defining the resource type
            # This prevents "can't add a new key into hash during iteration" errors
            assoc_type_map = {}
            schema_class.association_definitions.each do |name, association_definition|
              assoc_type_map[name] = TypeRegistry.register_association_type(contract_class, association_definition)
            end

            # NOW register the resource type (with nil, which uses contract prefix)
            Descriptors::Registry.register_local(contract_class, nil) do
              # All resource attributes
              schema_class.attribute_definitions.each do |name, attribute_definition|
                param name,
                      type: Generator.map_type(attribute_definition.type),
                      required: false,
                      **(attribute_definition.enum ? { enum: name } : {})
              end

              # Add associations using pre-registered types
              schema_class.association_definitions.each do |name, association_definition|
                assoc_type = assoc_type_map[name]

                if assoc_type
                  # Use the registered type
                  if association_definition.singular?
                    param name, type: assoc_type, required: false, nullable: association_definition.nullable?
                  elsif association_definition.collection?
                    param name, type: :array, of: assoc_type, required: false,
                                nullable: association_definition.nullable?
                  end
                elsif association_definition.singular?
                  # Fallback to generic types if no schema
                  param name, type: :object, required: false, nullable: association_definition.nullable?
                elsif association_definition.collection?
                  param name, type: :array, required: false, nullable: association_definition.nullable?
                end
              end
            end
          end
        end
      end
    end
  end
end
