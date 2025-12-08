# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseParser
      attr_reader :action_name,
                  :contract_class

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name.to_sym
      end

      def parse(body)
        definition = body_definition
        return ResponseResult.new(body, []) unless definition&.params&.any?

        validated = definition.validate(body) || { params: body, issues: [] }

        ResponseResult.new(validated[:params], validated[:issues])
      end

      private

      def action_definition
        @action_definition ||= contract_class.action_definition(action_name)
      end

      def body_definition
        action_definition&.response_definition&.body_definition
      end
    end
  end
end
