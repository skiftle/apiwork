# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Represents the request being processed through the adapter pipeline.
    #
    # Request encapsulates query parameters and request body as they
    # flow through normalization and preparation hooks. Each transformation
    # step receives a request and returns a new request.
    #
    # @example Creating a request
    #   request = Adapter::Request.new(query: { page: 1 }, body: { title: "Hello" })
    #   request.query  # => { page: 1 }
    #   request.body   # => { title: "Hello" }
    #
    # @example In adapter hooks
    #   def normalize_request(request)
    #     Request.new(
    #       query: transform(request.query),
    #       body: transform(request.body)
    #     )
    #   end
    #
    # @see Base#normalize_request
    # @see Base#prepare_request
    class Request
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

      # @api public
      # Transforms both query and body with the same block.
      #
      # @yield [Hash] each field (query, then body)
      # @return [Request] new context with transformed data
      #
      # @example
      #   request.transform { |data| normalize(data) }
      def transform
        self.class.new(body: yield(body), query: yield(query))
      end

      # @api public
      # Transforms only the query.
      #
      # @yield [Hash] the query parameters
      # @return [Request] new context with transformed query
      #
      # @example
      #   request.transform_query { |q| normalize(q) }
      def transform_query
        self.class.new(body: body, query: yield(query))
      end

      # @api public
      # Transforms only the body.
      #
      # @yield [Hash] the request body
      # @return [Request] new context with transformed body
      #
      # @example
      #   request.transform_body { |b| prepare(b) }
      def transform_body
        self.class.new(body: yield(body), query: query)
      end
    end
  end
end
