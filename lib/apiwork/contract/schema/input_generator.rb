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
            if filter_type
              definition.param :filter, type: :union, required: false do
                # Allow object form
                variant type: filter_type
                # Allow array form
                variant type: :array, of: filter_type
              end
            end

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
            unless Descriptor::Registry.resolve(payload_type_name, contract_class: contract_class)
              Descriptor::Registry.register_type(payload_type_name, scope: contract_class, api_class: contract_class.api_class) do
                InputGenerator.generate_writable_params(self, schema_class, context)
              end
            end

            # Create nested param with root key - REQUIRED (no flat format allowed)
            # Use the registered type
            definition.param root_key, type: payload_type_name, required: true
          end

          # Generate writable parameters from schema attributes and associations
          def generate_writable_params(definition, schema_class, context)
            # Generate from writable attributes
            schema_class.attribute_definitions.each do |name, attribute_definition|
              next unless attribute_definition.writable_for?(context)

              param_options = {
                type: Generator.map_type(attribute_definition.type),
                required: attribute_definition.required?, # Auto-detected from DB schema and model validations
                nullable: attribute_definition.nullable? # Auto-detected from DB schema or explicit config
              }

              # Reference registered enum by attribute name (registered at contract level)
              # E.g., :status references the :post_status enum
              param_options[:enum] = name if attribute_definition.enum

              definition.param name, **param_options
            end

            # Generate from writable associations
            schema_class.association_definitions.each do |name, association_definition|
              next unless association_definition.writable_for?(context)

              # Try to get the association's schema for typed payloads
              # Only use typed payloads when allow_destroy is false (typed payloads don't include _destroy)
              association_schema = TypeRegistry.resolve_association_resource(association_definition)
              association_payload_type = nil

              if association_schema && association_definition.allow_destroy == false
                # Try to auto-import the association's contract and reuse its payload type
                import_alias = TypeRegistry.auto_import_association_contract(
                  definition.contract_class,
                  association_schema,
                  Set.new
                )

                if import_alias
                  # Reference imported payload type: e.g., :comment_create_payload
                  association_payload_type = :"#{import_alias}_#{context}_payload"
                end
              end

              param_options = {
                required: false, # Associations are optional by default for input
                nullable: association_definition.nullable?,
                as: "#{name}_attributes".to_sym # Transform for Rails accepts_nested_attributes_for
              }

              # Set type based on whether we have a typed payload and whether it's a collection
              if association_payload_type
                if association_definition.collection?
                  param_options[:type] = :array
                  param_options[:of] = association_payload_type
                else
                  param_options[:type] = association_payload_type
                end
              else
                # Fall back to generic types (either because allow_destroy or no schema)
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
