# frozen_string_literal: true

module Apiwork
  module Contract
    class ResponseDefinition
      attr_reader :action_name,
                  :body_definition,
                  :contract_class

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name
        @body_definition = nil
        @no_content = false
      end

      def no_content?
        @no_content
      end

      # Declares this action returns 204 No Content.
      #
      # Use for actions that don't return a response body,
      # like DELETE or actions that only perform side effects.
      #
      # @example
      #   action :destroy do
      #     response { no_content! }
      #   end
      #
      # @example Archive action
      #   action :archive do
      #     response { no_content! }
      #   end
      def no_content!
        @no_content = true
      end

      # Defines the response body for this response.
      #
      # Use `param` inside the block to define fields.
      # When using schema!, body is auto-generated from schema attributes.
      #
      # @yield block defining body params
      # @return [Definition] the body definition
      #
      # @example
      #   response do
      #     body do
      #       param :id, type: :integer
      #       param :title, type: :string
      #       param :created_at, type: :datetime
      #     end
      #   end
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
