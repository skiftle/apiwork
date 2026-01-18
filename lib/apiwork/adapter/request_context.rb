# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Represents the request being processed through the adapter pipeline.
    #
    # RequestContext encapsulates query parameters and request body as they
    # flow through normalization and preparation hooks. Each transformation
    # step receives a context and returns a new context.
    #
    # @example Creating a request context
    #   request = Adapter::RequestContext.new(query: { page: 1 }, body: { title: "Hello" })
    #   request.query  # => { page: 1 }
    #   request.body   # => { title: "Hello" }
    #
    # @example In adapter hooks
    #   def normalize_request(request)
    #     RequestContext.new(
    #       query: transform(request.query),
    #       body: transform(request.body)
    #     )
    #   end
    #
    # @see Base#normalize_request
    # @see Base#prepare_request
    class RequestContext
      # @api public
      # @return [Hash] the query parameters
      attr_reader :query

      # @api public
      # @return [Hash] the request body
      attr_reader :body

      # @api public
      # Creates a new request context.
      #
      # @param query [Hash] the query parameters
      # @param body [Hash] the request body
      def initialize(body:, query:)
        @query = query
        @body = body
      end
    end
  end
end
