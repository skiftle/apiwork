# frozen_string_literal: true

module Apiwork
  module Contract
    # Defines query params and body for a request.
    #
    # Part of the Adapter DSL. Returned by {ActionDefinition#request}.
    # Use as a declarative builder - do not rely on internal state.
    #
    # @api public
    class RequestDefinition
      attr_reader :action_name,
                  :body_definition,
                  :contract_class,
                  :query_definition

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name
        @query_definition = nil
        @body_definition = nil
      end

      # Defines query parameters for this request.
      #
      # Query parameters are parsed from the URL query string.
      # Use `param` inside the block to define parameters.
      #
      # @yield block defining query params
      # @return [Definition] the query definition
      #
      # @example
      #   request do
      #     query do
      #       param :page, type: :integer, optional: true, default: 1
      #       param :per_page, type: :integer, optional: true, default: 25
      #       param :filter, type: :string, optional: true
      #     end
      #   end
      def query(&block)
        @query_definition ||= Definition.new(
          type: :query,
          contract_class: @contract_class,
          action_name: @action_name
        )

        @query_definition.instance_eval(&block) if block

        @query_definition
      end

      # Defines the request body for this request.
      #
      # Body is parsed from the JSON request body.
      # Use `param` inside the block to define fields.
      #
      # @yield block defining body params
      # @return [Definition] the body definition
      #
      # @example
      #   request do
      #     body do
      #       param :title, type: :string
      #       param :amount, type: :decimal, min: 0
      #     end
      #   end
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
