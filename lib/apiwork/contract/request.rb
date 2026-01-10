# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Defines query params and body for a request.
    #
    # Returns {Object} via `query` and `body`.
    class Request
      attr_reader :action_name,
                  :body_param,
                  :contract_class,
                  :query_param

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name
        @query_param = nil
        @body_param = nil
      end

      # @api public
      # Defines query parameters for this request.
      #
      # Query parameters are parsed from the URL query string.
      #
      # @return [Contract::Object]
      # @see Contract::Object
      #
      # @example
      #   query do
      #     param :page, type: :integer, optional: true
      #     param :status, enum: :status, optional: true
      #   end
      def query(&block)
        @query_param ||= Object.new(
          @contract_class,
          action_name: @action_name,
        )

        @query_param.instance_eval(&block) if block

        @query_param
      end

      # @api public
      # Defines the request body for this request.
      #
      # Body is parsed from the JSON request body.
      #
      # @return [Contract::Object]
      # @see Contract::Object
      #
      # @example
      #   body do
      #     param :title, type: :string
      #     param :amount, type: :decimal
      #   end
      def body(&block)
        @body_param ||= Object.new(
          @contract_class,
          action_name: @action_name,
        )

        @body_param.instance_eval(&block) if block

        @body_param
      end
    end
  end
end
