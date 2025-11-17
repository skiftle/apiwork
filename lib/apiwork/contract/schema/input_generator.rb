# frozen_string_literal: true

module Apiwork
  module Contract
    module Schema
      # Generates input schemas for CRUD actions
      # Handles query parameters (filter, sort, page, include) and writable input
      class InputGenerator
        class << self
          # Generate query parameters for index action
          # Creates filter, sort, page, and include parameters
          def generate_query_params(definition, schema_class)
            contract_class = definition.contract_class

            # Register resource-specific filter and sort types with Descriptor::Registry
            # This pre-registers all types before usage, eliminating circular recursion
            filter_type = TypeRegistry.register_resource_filter_type(contract_class, schema_class)
            sort_type = TypeRegistry.register_resource_sort_type(contract_class, schema_class)

            # Generate nested filter parameter with resource-specific filters
            definition.param :filter, type: filter_type, required: false if filter_type

            # Generate nested sort parameter
            if sort_type
              definition.param :sort, type: :union, required: false do
                # Allow single sort field
                variant type: sort_type
                # Allow array of sort fields
                variant type: :array, of: sort_type
              end
            end

            # Generate nested page parameter (uses global built-in type)
            definition.param :page, type: :page, required: false

            # Generate nested include parameter with strict validation
            # Type includes ALL associations - contract validates structure
            include_type = TypeRegistry.register_resource_include_type(contract_class, schema_class)
            definition.param :include, type: include_type, required: false
          end

          # Generate input contract with root key (like params.require(:service).permit(...))
          # Creates: {service: {icon: ..., name: ...}}
          # Registers the payload type with Descriptor::Registry for reusability
          def generate_writable_input(definition, schema_class, context)
            root_key = schema_class.root_key.singular.to_sym
            contract_class = definition.contract_class

            # Register the writable payload type with Descriptor::Registry
            # Use short name - Descriptor::Registry will add prefix via qualified_name
            # Example: :create_payload, :update_payload
            payload_type_name = :"#{context}_payload"

            # Check if already registered
            unless Descriptor::Registry.resolve_type(payload_type_name, contract_class: contract_class)
              Descriptor::Registry.register_type(payload_type_name, scope: contract_class, api_class: contract_class.api_class) do
                InputGenerator.generate_writable_params(self, schema_class, context, nested: false)
              end
            end

            # nested_payload union is registered lazily via auto_import_association_contract
            # when a schema is used as a writable association, not eagerly here

            # Create nested param with root key - REQUIRED (no flat format allowed)
            # Use the registered type
            definition.param root_key, type: payload_type_name, required: true
          end

          # Generate writable parameters from schema attributes and associations
          def generate_writable_params(definition, schema_class, context, nested: false)
            # Generate from writable attributes
            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.writable_for?(context)

              param_options = {
                type: Generator.map_type(attribute_definition.type),
                required: attribute_definition.required?, # Auto-detected from DB schema and model validations
                nullable: attribute_definition.nullable?, # Auto-detected from DB schema or explicit config
                attribute_definition: attribute_definition # Reference for deserialization transformers
              }

              # Add numeric constraints if present
              param_options[:min] = attribute_definition.min if attribute_definition.min
              param_options[:max] = attribute_definition.max if attribute_definition.max

              # Reference registered enum by attribute name (registered at contract level)
              # E.g., :status references the :post_status enum
              param_options[:enum] = name if attribute_definition.enum

              definition.param name, **param_options
            end

            # Generate from writable associations
            schema_class.association_definitions.each do |name, association_definition|
              next unless association_definition.writable_for?(context)

              # Try to get the association's schema for typed payloads
              association_schema = TypeRegistry.resolve_association_resource(association_definition)
              association_payload_type = nil

              association_contract = nil
              if association_schema
                # Try to auto-import the association's contract and reuse its payload type
                import_alias = TypeRegistry.auto_import_association_contract(
                  definition.contract_class,
                  association_schema,
                  Set.new
                )

                if import_alias
                  # Always use nested_payload type for nested associations (discriminated union)
                  association_payload_type = :"#{import_alias}_nested_payload"

                  # Get the association's contract for nested type resolution
                  # This is needed for deep nesting transformations
                  association_contract = SchemaRegistry.contract_for_schema(association_schema)
                end
              end

              param_options = {
                required: false, # Associations are optional by default for input
                nullable: association_definition.nullable?,
                as: "#{name}_attributes".to_sym # Transform for Rails accepts_nested_attributes_for
              }

              # Store the contract that owns the nested_payload type for later resolution
              param_options[:type_contract_class] = association_contract if association_contract

              # Set type based on whether we have a typed payload and whether it's a collection
              if association_payload_type
                if association_definition.collection?
                  param_options[:type] = :array
                  param_options[:of] = association_payload_type
                else
                  param_options[:type] = association_payload_type
                end
              else
                # Fall back to generic types when no schema exists
                param_options[:type] = association_definition.collection? ? :array : :object
              end

              definition.param name, **param_options
            end
          end
        end
      end
    end
  end
end
