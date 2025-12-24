# frozen_string_literal: true

module Apiwork
  module Contract
    # Defines body for a response.
    #
    # Returns {ParamDefinition} via `body`.
    # Use as a declarative builder - do not rely on internal state.
    #
    # @api public
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

      # @api public
      # Returns true if this response is 204 No Content.
      # @return [Boolean]
      def no_content?
        @no_content
      end

      # @api public
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

      # @api public
      # Defines the response body for this response.
      #
      # Use `param` inside the block to define fields.
      # When using schema!, body is auto-generated from schema attributes.
      #
      # @yield block defining body params
      # @return [ParamDefinition] the body param definition
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
        @body_definition ||= ParamDefinition.new(
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
