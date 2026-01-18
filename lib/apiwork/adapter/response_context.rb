# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Represents the response being processed through the adapter pipeline.
    #
    # ResponseContext encapsulates the response body as it flows through
    # transformation hooks.
    #
    # @example Creating a response context
    #   response = Adapter::ResponseContext.new(body: { id: 1, title: "Hello" })
    #   response.body  # => { id: 1, title: "Hello" }
    #
    # @example In adapter hooks
    #   def transform_response(response)
    #     ResponseContext.new(body: camelize_keys(response.body))
    #   end
    #
    # @see Base#transform_response
    class ResponseContext
      # @api public
      # @return [Hash] the response body
      attr_reader :body

      # @api public
      # Creates a new response context.
      #
      # @param body [Hash] the response body
      def initialize(body:)
        @body = body
      end

      # @api public
      # Transforms the response body.
      #
      # @yield [Hash] the response body
      # @return [ResponseContext] new context with transformed body
      #
      # @example
      #   response.transform { |data| camelize(data) }
      def transform
        self.class.new(body: yield(body))
      end

      # @api public
      # Transforms the response body.
      #
      # @yield [Hash] the response body
      # @return [ResponseContext] new context with transformed body
      #
      # @example
      #   response.transform_body { |data| camelize(data) }
      def transform_body
        self.class.new(body: yield(body))
      end
    end
  end
end
