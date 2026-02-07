# frozen_string_literal: true

module Apiwork
  module Contract
    class Action
      # Defines body for a response.
      #
      # Returns {Contract::Object} via `body`.
      #
      # @api public
      class Response
        attr_reader :action_name,
                    :contract_class

        attr_accessor :result_wrapper

        def initialize(contract_class, action_name)
          @contract_class = contract_class
          @action_name = action_name
          @body = nil
          @result_wrapper = nil
          @no_content = false
        end

        # @api public
        # Returns whether this response is 204 No Content.
        #
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
        #
        # @return [void]
        def no_content!
          @no_content = true
        end

        # @api public
        # Defines the response body for this response.
        #
        # When using representation, body is auto-generated from representation attributes.
        #
        # @yield block for defining body params (instance_eval style)
        # @yieldparam builder [Contract::Object] the builder (yield style)
        # @return [Contract::Object]
        # @see Contract::Object
        #
        # @example instance_eval style
        #   body do
        #     integer :id
        #     string :title
        #     decimal :amount
        #   end
        #
        # @example yield style
        #   body do |body|
        #     body.integer :id
        #     body.string :title
        #     body.decimal :amount
        #   end
        def body(&block)
          if block
            @body ||= Object.new(
              @contract_class,
              action_name: @action_name,
              wrapped: true,
            )
            block.arity.positive? ? yield(@body) : @body.instance_eval(&block)
          end
          @body
        end
      end
    end
  end
end
