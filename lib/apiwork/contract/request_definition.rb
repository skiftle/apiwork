# frozen_string_literal: true

module Apiwork
  module Contract
    class RequestDefinition
      attr_reader :action_name,
                  :body_definition,
                  :contract_class,
                  :query_definition

      def initialize(contract_class:, action_name:)
        @contract_class = contract_class
        @action_name = action_name
        @query_definition = nil
        @body_definition = nil
      end

      def query(&block)
        @query_definition ||= Definition.new(
          type: :query,
          contract_class: @contract_class,
          action_name: @action_name
        )

        @query_definition.instance_eval(&block) if block

        @query_definition
      end

      def body(&block)
        @body_definition ||= Definition.new(
          type: :body,
          contract_class: @contract_class,
          action_name: @action_name
        )

        @body_definition.instance_eval(&block) if block

        @body_definition
      end
    end
  end
end
