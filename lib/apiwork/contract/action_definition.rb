# frozen_string_literal: true

module Apiwork
  module Contract
    class ActionDefinition
      attr_reader :action_name,
                  :contract_class,
                  :request_definition,
                  :response_definition

      def schema_class
        contract_class.schema_class
      end

      def initialize(action_name:, contract_class:, replace: false)
        @action_name = action_name
        @contract_class = contract_class
        @reset_request = replace
        @reset_response = replace
        @request_definition = nil
        @response_definition = nil
        @error_codes = []

        return unless contract_class.schema?

        return if singleton_class.ancestors.include?(Adapter::Standard::ActionDefinitionExtension)

        singleton_class.prepend(Adapter::Standard::ActionDefinitionExtension)
      end

      def resets_request?
        @reset_request
      end

      def resets_response?
        @reset_response
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

      def request(replace: false, &block)
        @reset_request = replace if replace

        @request_definition ||= RequestDefinition.new(
          contract_class: contract_class,
          action_name: action_name
        )

        @request_definition.instance_eval(&block) if block

        @request_definition
      end

      def response(replace: false, &block)
        @reset_response = replace if replace

        @response_definition ||= ResponseDefinition.new(
          contract_class: contract_class,
          action_name: action_name
        )

        @response_definition.instance_eval(&block) if block

        @response_definition
      end

      def serialize_data(data, context: {}, includes: nil)
        data
      end
    end
  end
end
