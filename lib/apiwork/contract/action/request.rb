# frozen_string_literal: true

module Apiwork
  module Contract
    class Action
      # @api public
      # Defines query and body for a request.
      #
      # Returns {Contract::Object} via `query` and `body`.
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
        # @yield block for defining query params (instance_eval style)
        # @yieldparam query [Contract::Object]
        # @return [Contract::Object]
        #
        # @example instance_eval style
        #   query do
        #     integer? :page
        #     string? :status, enum: :status
        #   end
        #
        # @example yield style
        #   query do |query|
        #     query.integer? :page
        #     query.string? :status, enum: :status
        #   end
        def query(&block)
          @query ||= Object.new(@contract_class, action_name: @action_name)
          if block
            block.arity.positive? ? yield(@query) : @query.instance_eval(&block)
          end
          @query
        end

        # @api public
        # Defines the request body for this request.
        #
        # Body is parsed from the JSON request body.
        #
        # @yield block for defining body params (instance_eval style)
        # @yieldparam body [Contract::Object]
        # @return [Contract::Object]
        #
        # @example instance_eval style
        #   body do
        #     string :title
        #     decimal :amount
        #   end
        #
        # @example yield style
        #   body do |body|
        #     body.string :title
        #     body.decimal :amount
        #   end
        def body(&block)
          @body ||= Object.new(@contract_class, action_name: @action_name)
          if block
            block.arity.positive? ? yield(@body) : @body.instance_eval(&block)
          end
          @body
        end
      end
    end
  end
end
