# frozen_string_literal: true

module Apiwork
  module Contract
    class ActionDefinition
      attr_reader :action_name,
                  :contract_class,
                  :input_definition,
                  :output_definition

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
        @error_codes = []

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
        Apiwork::Introspection.action_definition(self)
      end

      def as_json
        introspect
      end

      def error_codes(*codes)
        @error_codes = codes.flatten.map(&:to_i)
      end

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

      def merged_input_definition
        input_definition
      end

      def merged_output_definition
        output_definition
      end

      def serialize_data(data, context: {}, includes: nil)
        data
      end

      private

      def find_api_for_contract
        Apiwork::API.all.find do |api_class|
          next unless api_class.metadata

          search_in_metadata(api_class.metadata) { |resource| matches_contract?(resource) }
        end
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
