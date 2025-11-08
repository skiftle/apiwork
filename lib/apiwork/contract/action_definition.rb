# frozen_string_literal: true

module Apiwork
  module Contract
    # Represents the contract definition for a single action
    # Handles input/output definitions, merging with schema, and serialization
    class ActionDefinition
      attr_reader :action_name, :contract_class, :parent_scope

      # Get the schema class from the contract
      # Convenience method to avoid Law of Demeter violations
      #
      # @return [Class, nil] The schema class or nil if contract has no schema
      def schema_class
        contract_class.schema_class
      end

      def initialize(action_name, contract_class)
        @action_name = action_name
        @contract_class = contract_class
        @parent_scope = contract_class  # Parent scope is the contract class
        @reset_input = false
        @reset_output = false
        @input_definition = nil
        @output_definition = nil
        @error_codes = []  # Action-specific error codes

        # Conditionally prepend Schema::ActionDefinition if contract has schema
        return unless contract_class.schema?

        return if singleton_class.ancestors.include?(Schema::ActionDefinition)

        singleton_class.prepend(Schema::ActionDefinition)
      end

      # Reset flags to override virtual contracts
      def reset_input!
        @reset_input = true
      end

      def reset_output!
        @reset_output = true
      end

      def resets_input?
        @reset_input
      end

      def resets_output?
        @reset_output
      end

      def merges_input?
        false
      end

      def merges_output?
        false
      end

      # Serialize this action definition to JSON-friendly hash
      # Includes both input and output definitions
      # @return [Hash] Hash with :input and :output keys
      def as_json
        result = {}
        result[:input] = merged_input_definition&.as_json
        result[:output] = merged_output_definition&.as_json

        # Include error codes (merged with API-level global codes)
        merged_codes = all_error_codes
        result[:error_codes] = merged_codes if merged_codes.any?

        result
      end

      # Define a custom type scoped to this action
      def type(name, &block)
        raise ArgumentError, 'Block required for custom type definition' unless block_given?

        # Register type scoped to this ActionDefinition instance (not contract class)
        # This ensures action-scoped types are isolated from other actions
        Descriptors::Registry.register_local(self, name, &block)
      end

      # Define an enum at action level
      # Enums defined here are available in this action's input and output
      #
      # @param name [Symbol] Name of the enum (e.g., :priority)
      # @param values [Array] Array of allowed values (e.g., %w[low high])
      #
      # @example
      #   action :create do
      #     enum :priority, %w[low medium high]
      #
      #     input do
      #       param :priority, type: :string, enum: :priority
      #     end
      #   end
      def enum(name, values)
        raise ArgumentError, 'Values array required for enum definition' unless values.is_a?(Array)

        # Register with Descriptors::Registry using this ActionDefinition instance as scope
        # This creates action-level scoping for the enum
        Descriptors::Registry.register_local_enum(self, name, values)
      end

      # Define action-specific error codes that can be returned
      # These codes are merged with API-level global error codes
      #
      # @param codes [Array<Integer>] HTTP status codes specific to this action
      #
      # @example
      #   action :show do
      #     error_codes 404, 403  # Not found, forbidden
      #
      #     input do
      #       param :id, type: :integer
      #     end
      #   end
      def error_codes(*codes)
        @error_codes = codes.flatten.map(&:to_i)
      end

      # Define input for this action
      def input(&block)
        @input_definition ||= Definition.new(
          :input,
          contract_class,
          type_scope: nil,  # No longer needed with parent_scope chain
          action_name: action_name,
          parent_scope: self  # THIS ActionDefinition is the parent
        )

        @input_definition.instance_eval(&block) if block

        @input_definition
      end

      # Define output for this action
      def output(&block)
        @output_definition ||= Definition.new(
          :output,
          contract_class,
          type_scope: nil,  # No longer needed with parent_scope chain
          action_name: action_name,
          parent_scope: self  # THIS ActionDefinition is the parent
        )

        @output_definition.instance_eval(&block) if block

        @output_definition
      end

      # Get input definition
      attr_reader :input_definition

      # Get output definition
      attr_reader :output_definition

      # Get merged input definition (virtual + explicit)
      def merged_input_definition
        return input_definition unless merges_input?
        return input_definition if input_definition.nil?

        # For now, just return explicit input
        # TODO: Implement full merging when needed
        input_definition
      end

      # Get merged output definition (virtual + explicit)
      def merged_output_definition
        output_definition
      end

      # Validate complete response structure (like Zod.parse())
      # Called by Controller after response is fully built
      # @param response [Hash] Complete response with ok, root key, data, meta
      # @return [Hash] Validated response
      # @raise [ValidationError] If output doesn't match definition
      def validate_response(response)
        merged_output = merged_output_definition

        # Custom actions without explicit output definition skip validation
        return response unless merged_output

        # Validate complete response structure
        validate_output_data(response, merged_output)

        response
      end

      # Serialize data (base version: no-op, returns data as-is)
      # @param data [Object] Data to serialize
      # @param context [Hash] Context for serialization
      # @param includes [Hash, nil] Includes from query params
      # @return [Hash, Array] Serialized data
      def serialize_data(data, context: {}, includes: nil)
        data
      end

      private

      # Get all error codes (API-level global + action-specific + auto-generated)
      # Returns a unique, sorted array of HTTP status codes
      def all_error_codes
        api_codes = api_error_codes
        action_codes = @error_codes || []
        auto_codes = auto_writable_error_codes

        # Merge all three sources and deduplicate
        (api_codes + action_codes + auto_codes).uniq.sort
      end

      # Auto-add 422 for writable actions based on HTTP method
      # Only applies to schema-based contracts
      # Returns [422] for POST/PATCH/PUT actions, [] for GET/DELETE
      def auto_writable_error_codes
        return [] unless contract_class.schema?

        # CRUD writable actions always get 422
        return [422] if [:create, :update].include?(action_name.to_sym)

        # Read-only CRUD actions don't get 422
        return [] if [:index, :show, :destroy].include?(action_name.to_sym)

        # Custom actions: check HTTP method from API metadata
        http_method = find_http_method_from_api_metadata
        return [] unless http_method

        # POST, PATCH, PUT get 422
        [:post, :patch, :put].include?(http_method) ? [422] : []
      end

      # Find HTTP method for this action from API metadata
      # Searches member and collection actions in the resource metadata (recursively for nested resources)
      # @return [Symbol, nil] HTTP method (:get, :post, :patch, :put, :delete) or nil
      def find_http_method_from_api_metadata
        api = find_api_for_contract
        return nil unless api&.metadata

        # Search all resources (including nested)
        search_http_method_in_resources(api.metadata.resources)
      end

      # Recursively search for HTTP method in resources and nested resources
      def search_http_method_in_resources(resources)
        resources.each_value do |resource_metadata|
          # Only check resources that use this contract
          if resource_uses_contract?(resource_metadata, contract_class)
            # Check member actions
            if resource_metadata[:members]&.key?(action_name.to_sym)
              return resource_metadata[:members][action_name.to_sym][:method]
            end

            # Check collection actions
            if resource_metadata[:collections]&.key?(action_name.to_sym)
              return resource_metadata[:collections][action_name.to_sym][:method]
            end
          end

          # Recursively search nested resources
          if resource_metadata[:resources]&.any?
            result = search_http_method_in_resources(resource_metadata[:resources])
            return result if result
          end
        end

        nil
      end

      # Get global error codes from the API definition
      # Searches through all registered APIs to find the one containing this contract
      def api_error_codes
        # Find the API that contains this contract class
        api = find_api_for_contract

        return [] unless api&.metadata

        api.metadata.error_codes || []
      end

      # Find the API definition class that contains this contract
      def find_api_for_contract
        # Search all registered APIs
        Apiwork::API.all.find do |api_class|
          next unless api_class.metadata

          # Check if this contract is used in any of the API's resources
          contract_used_in_api?(api_class, contract_class)
        end
      end

      # Check if a contract class is used in an API (recursively checks nested resources)
      def contract_used_in_api?(api_class, contract)
        api_class.metadata.resources.each_value do |resource_metadata|
          return true if resource_uses_contract?(resource_metadata, contract)
        end

        false
      end

      # Check if a resource (or its nested resources) uses a specific contract
      def resource_uses_contract?(resource_metadata, contract)
        # Check explicit contract
        if resource_metadata[:contract_class_name]
          begin
            resource_contract = resource_metadata[:contract_class_name].constantize
            return true if resource_contract == contract
          rescue NameError
            # Contract doesn't exist
          end
        end

        # Check schema-based contract (would need to instantiate to compare)
        # For now, we can compare by schema class if contract has one
        if resource_metadata[:schema_class] && contract.schema_class
          return true if resource_metadata[:schema_class] == contract.schema_class
        end

        # Check nested resources recursively
        if resource_metadata[:resources]&.any?
          resource_metadata[:resources].each_value do |nested_resource|
            return true if resource_uses_contract?(nested_resource, contract)
          end
        end

        false
      end

      def standard_crud_action?
        %i[index show create update destroy].include?(action_name.to_sym)
      end

      # Validate output data against definition
      # For collections (arrays), validates each item (excluding meta which is response-level)
      # For single objects, validates the object
      def validate_output_data(data, definition)
        if data.is_a?(Array)
          # For collections, validate each item but skip meta validation
          # Meta is added at response level, not per-item
          item_definition_params = definition.params.reject { |k, _v| k == :meta }

          data.each do |item|
            validate_single_output(item, definition, item_definition_params)
          end
        else
          # For single object, validate everything including meta
          validate_single_output(data, definition, definition.params)
        end
      end

      # Validate a single output object against definition
      def validate_single_output(data, definition, params_to_validate = nil)
        return unless data.is_a?(Hash)

        params_to_validate ||= definition.params

        params_to_validate.each do |param_name, param_options|
          value = data[param_name] || data[param_name.to_s]

          # Check required fields
          if param_options[:required] && value.nil?
            raise ValidationError.new(
              code: :missing_field,
              detail: "Required field '#{param_name}' is missing in output"
            )
          end

          # Validate nested objects if present
          if value && param_options[:nested] && value.is_a?(Hash)
            validate_single_output(value, param_options[:nested], param_options[:nested].params)
          end

          # Validate arrays of nested objects
          next unless value && param_options[:type] == :array && param_options[:nested] && value.is_a?(Array)

          value.each do |item|
            validate_single_output(item, param_options[:nested], param_options[:nested].params) if item.is_a?(Hash)
          end
        end
      end

      # Check if action is a writable action (create/update)
      def writable_action?
        %i[create update].include?(action_name.to_sym)
      end
    end
  end
end
