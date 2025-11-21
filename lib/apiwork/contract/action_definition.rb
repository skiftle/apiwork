# frozen_string_literal: true

module Apiwork
  module Contract
    # Represents the contract definition for a single action
    # Handles input/output definitions, merging with schema, and serialization
    class ActionDefinition
      attr_reader :action_name, :contract_class

      def schema_class
        contract_class.schema_class
      end

      def initialize(action_name:, contract_class:, replace: false)
        @action_name = action_name
        @contract_class = contract_class
        @reset_input = replace
        @reset_output = replace
        @input_definition = nil
        @output_definition = nil
        @error_codes = [] # Action-specific error codes

        # Conditionally prepend Schema::ActionDefinition if contract has schema
        return unless contract_class.schema?

        return if singleton_class.ancestors.include?(Schema::ActionDefinition)

        singleton_class.prepend(Schema::ActionDefinition)
      end

      def resets_input?
        @reset_input
      end

      def resets_output?
        @reset_output
      end

      def introspect
        result = {}
        result[:input] = merged_input_definition&.as_json
        result[:output] = merged_output_definition&.as_json

        # Always include error_codes (empty array if no action-specific codes)
        # Global codes are in json[:error_codes], consumers merge them
        result[:error_codes] = all_error_codes

        result
      end

      def as_json
        introspect
      end

      def error_codes(*codes)
        @error_codes = codes.flatten.map(&:to_i)
      end

      # Define input for this action
      def input(replace: false, &block)
        @reset_input = replace if replace

        @input_definition ||= Definition.new(
          type: :input,
          contract_class: contract_class,
          action_name: action_name
        )

        @input_definition.instance_eval(&block) if block

        @input_definition
      end

      # Define output for this action
      def output(replace: false, &block)
        @reset_output = replace if replace

        @output_definition ||= Definition.new(
          type: :output,
          contract_class: contract_class,
          action_name: action_name
        )

        @output_definition.instance_eval(&block) if block

        @output_definition
      end

      # Get input definition
      attr_reader :input_definition

      # Get output definition
      attr_reader :output_definition

      # Get merged input definition (virtual + explicit)
      # Base implementation just returns input definition
      # Schema::ActionDefinition overrides this for schema-based contracts
      def merged_input_definition
        input_definition
      end

      # Get merged output definition (virtual + explicit)
      def merged_output_definition
        output_definition
      end

      def serialize_data(data, context: {}, includes: nil)
        data
      end

      private

      # Get action-specific error codes (action-specific + auto-generated)
      # Does NOT include API-level global codes (those are in json[:error_codes])
      # Returns a unique, sorted array of HTTP status codes
      # Consumers should merge: api.error_codes + (action.error_codes || [])
      def all_error_codes
        action_codes = @error_codes || []
        auto_codes = auto_writable_error_codes

        # Merge action-specific and auto-generated codes only
        (action_codes + auto_codes).uniq.sort
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

      def find_http_method_from_api_metadata
        search_in_api_metadata do |resource_metadata|
          next unless matches_contract?(resource_metadata)

          # Check member actions
          return resource_metadata[:members][action_name.to_sym][:method] if resource_metadata[:members]&.key?(action_name.to_sym)

          # Check collection actions
          resource_metadata[:collections][action_name.to_sym][:method] if resource_metadata[:collections]&.key?(action_name.to_sym)
        end
      end

      # Find the API definition class that contains this contract
      def find_api_for_contract
        Apiwork::API.all.find do |api_class|
          next unless api_class.metadata

          search_in_metadata(api_class.metadata) { |resource| matches_contract?(resource) }
        end
      end

      def search_in_api_metadata(&block)
        api = find_api_for_contract
        return nil unless api&.metadata

        search_in_metadata(api.metadata, &block)
      end

      def search_in_metadata(metadata, &block)
        metadata.search_resources(&block)
      end

      def matches_contract?(resource_metadata)
        resource_uses_contract?(resource_metadata, contract_class)
      end

      def resource_uses_contract?(resource_metadata, contract)
        matches_contract_option?(resource_metadata, contract) ||
          matches_schema_contract?(resource_metadata, contract)
      end

      # Check if resource explicitly specifies this contract via contract: option
      def matches_contract_option?(resource_metadata, contract)
        contract_class = resource_metadata[:contract_class]
        return false unless contract_class

        contract_class == contract
      end

      def matches_schema_contract?(resource_metadata, contract)
        schema_class = resource_metadata[:schema_class]
        return false unless schema_class
        return false unless contract.schema_class

        schema_class == contract.schema_class
      end
    end
  end
end
