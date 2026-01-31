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

      def parse(response)
        body = response.body
        return ResponseResult.new(response:) unless body_shape&.params&.any?

        validated = body_shape.validate(body)
        validated_response = Response.new(body: validated[:params])

        ResponseResult.new(issues: validated[:issues], response: validated_response)
      end

      private

      def action
        @action ||= contract_class.action_for(action_name)
      end

      def body_shape
        action&.response&.body
      end
    end
  end
end
