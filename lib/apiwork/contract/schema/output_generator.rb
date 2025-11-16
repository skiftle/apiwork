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

            # Register the resource type with Descriptor::Registry
            # Use nil for registration - Descriptor::Registry will use just the prefix (e.g., "locale", "post")
            # Get the qualified name for reference
            resource_type_name = Descriptor::Registry.scoped_name(contract_class, nil)

            # Check if already registered
            unless Descriptor::Registry.resolve_type(resource_type_name, contract_class: contract_class)
              register_resource_type(contract_class, schema_class, root_key)
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
            definition.param :issues, type: :array, of: :issue, required: false
          end

          # Generate output for collection actions (index)
          # Returns unwrapped discriminated union with ok field and pagination
          def generate_collection_output(definition, schema_class)
            root_key = schema_class.root_key.singular.to_sym
            root_key_plural = schema_class.root_key.plural.to_sym
            contract_class = definition.contract_class

            # Register the resource type with Descriptor::Registry (same as single output)
            # Use nil for registration - Descriptor::Registry will use just the prefix
            # Get the qualified name for reference
            resource_type_name = Descriptor::Registry.scoped_name(contract_class, nil)

            # Check if already registered
            unless Descriptor::Registry.resolve_type(resource_type_name, contract_class: contract_class)
              register_resource_type(contract_class, schema_class, root_key)
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
              param :pagination, type: :pagination, required: true
            end

            # Error fields (ok: false variant)
            definition.param :issues, type: :array, of: :issue, required: false
          end

          private

          # Register resource type with all attributes and associations
          def register_resource_type(contract_class, schema_class, type_name)
            # PRE-REGISTER: Register all association types BEFORE defining the resource type
            # This prevents "can't add a new key into hash during iteration" errors
            assoc_type_map = {}
            schema_class.association_definitions.each do |name, association_definition|
              assoc_type_map[name] = TypeRegistry.register_association_type(contract_class, association_definition)
            end

            # PRE-REGISTER: Register all enum types BEFORE defining the resource type
            # This allows param to resolve enum references and auto-generates filter types
            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.enum

              enum_values = attribute_definition.enum
              Descriptor::Registry.register_enum(name, enum_values, scope: contract_class,
                                                                    api_class: contract_class.api_class)
            end

            # NOW register the resource type with the root key as the name
            # This ensures the type can be resolved later using the same name
            Descriptor::Registry.register_type(type_name, scope: contract_class, api_class: contract_class.api_class) do
              # All resource attributes
              # Keep snake_case for introspect consistency (transformation happens during serialization)
              schema_class.attribute_definitions.each do |name, attribute_definition|
                # Build enum option - use symbol reference to pre-registered enum
                enum_option = attribute_definition.enum ? { enum: name } : {}

                param name,
                      type: Generator.map_type(attribute_definition.type),
                      required: false,
                      **enum_option
              end

              # Add associations using pre-registered types
              # Keep snake_case for introspect consistency
              # :always associations are required, :optional are not
              schema_class.association_definitions.each do |name, association_definition|
                assoc_type = assoc_type_map[name]
                is_required = association_definition.always_included?

                if assoc_type
                  # Use the registered type
                  if association_definition.singular?
                    param name, type: assoc_type, required: is_required, nullable: association_definition.nullable?
                  elsif association_definition.collection?
                    param name, type: :array, of: assoc_type, required: is_required,
                                nullable: association_definition.nullable?
                  end
                elsif association_definition.singular?
                  # Fallback to generic types if no schema
                  param name, type: :object, required: is_required, nullable: association_definition.nullable?
                elsif association_definition.collection?
                  param name, type: :array, required: is_required, nullable: association_definition.nullable?
                end
              end
            end
          end
        end
      end
    end
  end
end
