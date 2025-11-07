# frozen_string_literal: true

module Apiwork
  module Generation
    # ComponentRegistry - Extracts and manages schema components from API contracts
    #
    # Analyzes action contracts and extracts:
    # - Input schemas (CreatePostInput, UpdatePostInput)
    # - Output schemas (Post, PostList)
    # - Nested object schemas (AuthorInput)
    # - Custom type schemas
    #
    # Uses SchemaRegistry for deduplication via shape fingerprinting.
    #
    # @example Extract components from API
    #   registry = ComponentRegistry.new
    #   api_json = API.find('/api/v1').as_json
    #
    #   registry.extract_components(api_json)
    #   registry.components # => { 'CreatePostInput' => {...}, 'Post' => {...}, ... }
    class ComponentRegistry
      attr_reader :components

      def initialize
        @components = {}
        @schema_registry = SchemaRegistry.new
      end

      # Extract all components from API introspection data
      #
      # @param api_data [Hash] Output from API.as_json
      # @return [void]
      def extract_components(api_data)
        return unless api_data[:resources]

        api_data[:resources].each do |resource_name, resource_data|
          extract_resource_components(resource_name, resource_data)
        end
      end

      # Get component name for a contract definition
      # Returns existing component if shape matches, creates new one otherwise
      #
      # @param suggested_name [String] Suggested component name
      # @param definition [Hash] Contract definition
      # @return [String] Component name
      def component_for(suggested_name, definition)
        # Check if we already have this exact shape
        existing = @schema_registry.find_by_shape(definition)
        return existing if existing

        # Register new component
        component_name = @schema_registry.register(suggested_name, definition)
        @components[component_name] = definition
        component_name
      end

      private

      # Extract components from a resource and its nested resources
      def extract_resource_components(resource_name, resource_data)
        # Extract CRUD action input/output components
        extract_action_components(resource_name, resource_data[:contracts]) if resource_data[:contracts]

        # Extract member action components
        extract_custom_action_components(resource_name, resource_data[:members]) if resource_data[:members]

        # Extract collection action components
        extract_custom_action_components(resource_name, resource_data[:collections]) if resource_data[:collections]

        # Recursively handle nested resources
        if resource_data[:resources]
          resource_data[:resources].each do |nested_name, nested_data|
            extract_resource_components(nested_name, nested_data)
          end
        end
      end

      # Extract input/output components from CRUD actions
      def extract_action_components(resource_name, contracts)
        contracts.each do |action_name, contract_data|
          next unless contract_data

          # Extract input schema (wrap params hash as object)
          if contract_data[:input] && contract_data[:input].any?
            input_name = build_input_name(resource_name, action_name)
            input_schema = wrap_params_as_object(contract_data[:input])
            extract_nested_components(input_schema)
            component_for(input_name, input_schema)
          end

          # Extract output schema (wrap params hash as object)
          if contract_data[:output] && contract_data[:output].any?
            output_name = build_output_name(resource_name, action_name)
            output_schema = wrap_params_as_object(contract_data[:output])
            extract_nested_components(output_schema)
            component_for(output_name, output_schema)
          end
        end
      end

      # Extract components from custom actions (member/collection)
      def extract_custom_action_components(resource_name, actions)
        actions.each do |action_name, action_data|
          contract_data = action_data[:contract]
          next unless contract_data

          # Extract input schema (wrap params hash as object)
          if contract_data[:input] && contract_data[:input].any?
            input_name = build_input_name(resource_name, action_name)
            input_schema = wrap_params_as_object(contract_data[:input])
            extract_nested_components(input_schema)
            component_for(input_name, input_schema)
          end

          # Extract output schema (wrap params hash as object)
          if contract_data[:output] && contract_data[:output].any?
            output_name = build_output_name(resource_name, action_name)
            output_schema = wrap_params_as_object(contract_data[:output])
            extract_nested_components(output_schema)
            component_for(output_name, output_schema)
          end
        end
      end

      # Recursively extract nested object and custom type components
      def extract_nested_components(definition)
        case definition[:type]
        when 'object'
          # Extract nested objects with shape as separate components
          extract_nested_objects(definition[:shape]) if definition[:shape]

        when 'array'
          # Recurse into array item type
          extract_nested_components(definition[:of]) if definition[:of]

        when 'union'
          # Recurse into union variants
          definition[:variants]&.each { |type_def| extract_nested_components(type_def) }

        when 'custom'
          # Custom types always become components
          if definition[:custom_type] && definition[:shape]
            custom_name = definition[:custom_type]
            component_for(custom_name, definition)
          end
        end
      end

      # Extract nested objects from a shape hash
      def extract_nested_objects(shape)
        shape.each do |property_name, property_def|
          # If this property is an object with a shape, extract it as a component
          if property_def[:type] == 'object' && property_def[:shape]
            nested_name = "#{property_name}_input"
            component_for(nested_name, property_def)
          end

          # Recurse into nested structures
          extract_nested_components(property_def)
        end
      end

      # Wrap a params hash as an object schema
      # Converts {param_name => param_def, ...} to {type: 'object', shape: {...}, required: [...]}
      def wrap_params_as_object(params_hash)
        required_params = params_hash.select { |_name, param_def| param_def[:required] }.keys

        {
          type: 'object',
          shape: params_hash,
          required: required_params
        }
      end

      # Build input schema name for an action
      # @return [String] e.g., 'create_post_input', 'publish_post_input'
      def build_input_name(resource_name, action_name)
        "#{action_name}_#{resource_name.to_s.singularize}_input"
      end

      # Build output schema name for an action
      # @return [String] e.g., 'post', 'post_list'
      def build_output_name(resource_name, action_name)
        case action_name
        when :index
          "#{resource_name.to_s.singularize}_list"
        else
          resource_name.to_s.singularize
        end
      end
    end
  end
end
