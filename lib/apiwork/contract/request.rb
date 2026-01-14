# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Defines query params and body for a request.
    #
    # Returns {Object} via `query` and `body`.
    class Request
      attr_reader :action_name,
                  :contract_class

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name
        @query = nil
        @body = nil
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
      #     integer :page, optional: true
      #     string :status, enum: :status, optional: true
      #   end
      def query(&block)
        if block
          @query ||= Object.new(
            @contract_class,
            action_name: @action_name,
          )
          @query.instance_eval(&block)
        end
        @query
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
      #     string :title
      #     decimal :amount
      #   end
      def body(&block)
        if block
          @body ||= Object.new(
            @contract_class,
            action_name: @action_name,
          )
          @body.instance_eval(&block)
        end
        @body
      end
    end
  end
end
