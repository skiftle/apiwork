# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseDefinition
      attr_reader :action_name,
                  :body_definition,
                  :contract_class

      def initialize(contract_class:, action_name:)
        @contract_class = contract_class
        @action_name = action_name
        @body_definition = nil
        @no_content = false
      end

      def no_content?
        @no_content
      end

      def no_content!
        @no_content = true
      end

      def body(&block)
        @body_definition ||= Definition.new(
          type: :response_body,
          contract_class: @contract_class,
          action_name: @action_name
        )

        @body_definition.instance_eval(&block) if block

        @body_definition
      end
    end
  end
end
