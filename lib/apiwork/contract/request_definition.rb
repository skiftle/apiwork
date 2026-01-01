# frozen_string_literal: true

module Apiwork
  module Contract
    # Defines query params and body for a request.
    #
    # Returns {ParamDefinition} via `query` and `body`.
    # Use as a declarative builder - do not rely on internal state.
    #
    # @api public
    class RequestDefinition
      attr_reader :action_name,
                  :body_param_definition,
                  :contract_class,
                  :query_param_definition

      def initialize(contract_class, action_name)
        @contract_class = contract_class
        @action_name = action_name
        @query_param_definition = nil
        @body_param_definition = nil
      end

      # @api public
      # Defines query parameters for this request.
      #
      # Query parameters are parsed from the URL query string.
      # Use `param` inside the block to define parameters.
      #
      # @yield block defining query params
      # @return [ParamDefinition] the query param definition
      # @see Contract::ParamDefinition
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
        @query_param_definition ||= ParamDefinition.new(
          @contract_class,
          action_name: @action_name,
        )

        @query_param_definition.instance_eval(&block) if block

        @query_param_definition
      end

      # @api public
      # Defines the request body for this request.
      #
      # Body is parsed from the JSON request body.
      # Use `param` inside the block to define fields.
      #
      # @yield block defining body params
      # @return [ParamDefinition] the body param definition
      # @see Contract::ParamDefinition
      #
      # @example
      #   request do
      #     body do
      #       param :title, type: :string
      #       param :amount, type: :decimal, min: 0
      #     end
      #   end
      def body(&block)
        @body_param_definition ||= ParamDefinition.new(
          @contract_class,
          action_name: @action_name,
        )

        @body_param_definition.instance_eval(&block) if block

        @body_param_definition
      end
    end
  end
end
