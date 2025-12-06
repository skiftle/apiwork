# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseParser
      attr_reader :action,
                  :contract_class

      def initialize(contract_class, action:)
        @contract_class = contract_class
        @action = action.to_sym
      end

      def perform(body:)
        definition = body_definition
        return ResponseResult.new(body:, issues: []) unless definition&.params&.any?

        validated = definition.validate(body) || { params: body, issues: [] }

        ResponseResult.new(body: validated[:params], issues: validated[:issues])
      end

      private

      def action_definition
        @action_definition ||= contract_class.action_definition(action)
      end

      def body_definition
        action_definition&.response_definition&.body_definition
      end
    end
  end
end
