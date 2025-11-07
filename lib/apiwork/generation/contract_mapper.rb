# frozen_string_literal: true

module Apiwork
  module Generation
    # ContractMapper - Maps contract definitions to target schema formats
    #
    # Converts Contract.as_json output to various schema formats (OpenAPI, Zod, etc.)
    # Handles all contract features dynamically:
    # - Primitives (string, integer, boolean, etc.)
    # - Objects with shapes
    # - Arrays
    # - Enums
    # - Unions (oneOf)
    # - Custom types (with $ref)
    # - Nested objects (with $ref)
    #
    # @example Convert to OpenAPI
    #   mapper = ContractMapper::OpenAPI.new(component_registry)
    #   definition = { type: 'object', shape: { name: { type: 'string' } } }
    #   schema = mapper.map(definition)
    #   # => { type: 'object', properties: { name: { type: 'string' } }, required: [...] }
    module ContractMapper
      # OpenAPI 3.1.0 mapper
      class OpenAPI
        def initialize(component_registry)
          @component_registry = component_registry
        end

        # Map a contract definition to OpenAPI schema
        #
        # @param definition [Hash] Contract definition from as_json
        # @param component_name [String, nil] If provided, use $ref instead of inline
        # @return [Hash] OpenAPI schema
        def map(definition, component_name: nil)
          return { '$ref': "#/components/schemas/#{component_name}" } if component_name
          return { type: 'string' } unless definition # Fallback for nil

          # Normalize type to symbol for consistent comparison
          type = definition[:type].to_sym

          case type
          when :object
            map_object(definition)
          when :array
            map_array(definition)
          when :union
            map_union(definition)
          when :enum
            map_enum(definition)
          when :custom
            map_custom(definition)
          else
            map_primitive(definition)
          end
        end

        private

        # Map object type to OpenAPI schema
        def map_object(definition)
          result = {
            type: 'object',
            properties: {}
          }

          # Map each property
          if definition[:shape]
            definition[:shape].each do |property_name, property_def|
              result[:properties][property_name] = map_property(property_def)
            end
          end

          # Add required fields (only if it's an array with elements)
          if definition[:required].is_a?(Array) && definition[:required].any?
            result[:required] = definition[:required]
          end

          result
        end

        # Map a property (checks if it should be a $ref)
        def map_property(property_def)
          type = property_def[:type].to_sym

          # Custom types become references
          if type == :custom && property_def[:custom_type]
            return { '$ref': "#/components/schemas/#{build_component_name(property_def[:custom_type])}" }
          end

          # Otherwise map inline (including nested objects)
          map(property_def)
        end

        # Build component name from snake_case
        def build_component_name(name)
          name.to_s.split('_').map(&:capitalize).join
        end

        # Map array type to OpenAPI schema
        def map_array(definition)
          items_def = definition[:of]

          # If :of is a string (like "integer"), convert to hash format
          items_def = { type: items_def } if items_def.is_a?(String) || items_def.is_a?(Symbol)

          {
            type: 'array',
            items: map(items_def)
          }
        end

        # Map union type to OpenAPI oneOf
        def map_union(definition)
          variants = definition[:variants] || []
          {
            oneOf: variants.map { |type_def| map(type_def) }
          }
        end

        # Map enum type to OpenAPI enum
        def map_enum(definition)
          base = map_primitive(definition)
          base[:enum] = definition[:values]
          base
        end

        # Map custom type to OpenAPI $ref
        def map_custom(definition)
          { '$ref': "#/components/schemas/#{definition[:custom_type]}" }
        end

        # Map primitive type to OpenAPI schema
        def map_primitive(definition)
          schema = {
            type: openapi_type(definition[:type])
          }

          # Add format if present
          schema[:format] = definition[:format] if definition[:format]

          schema
        end

        # Convert contract type to OpenAPI type
        def openapi_type(type)
          type_sym = type.to_sym

          case type_sym
          when :string
            'string'
          when :integer
            'integer'
          when :boolean
            'boolean'
          when :number
            'number'
          when :enum
            'string' # Enums are strings with enum constraint
          when :date, :datetime
            'string'
          else
            'string' # Default fallback
          end
        end
      end
    end
  end
end
