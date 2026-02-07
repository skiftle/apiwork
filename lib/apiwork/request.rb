# frozen_string_literal: true

module Apiwork
  # @api public
  # Immutable value object representing a request.
  #
  # Encapsulates query and body parameters. Transformations return
  # new instances, preserving immutability.
  #
  # @example Creating a request
  #   request = Request.new(query: { page: 1 }, body: { title: "Hello" })
  #   request.query  # => { page: 1 }
  #   request.body   # => { title: "Hello" }
  #
  # @example Transforming keys
  #   request.transform { |data| normalize(data) }
  class Request
    # @api public
    # @return [Hash] the query parameters
    attr_reader :query

    # @api public
    # @return [Hash] the body parameters
    attr_reader :body

    # @api public
    # Creates a new request context.
    #
    # @param body [Hash] the body parameters
    # @param query [Hash] the query parameters
    def initialize(body:, query:)
      @query = query
      @body = body
    end

    # @api public
    # Transforms both query and body with the same block.
    #
    # @yield [Hash] each field (query, then body)
    # @return [Request] the transformed request
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
    # @return [Request] the transformed request
    #
    # @example
    #   request.transform_query { |query| normalize(query) }
    def transform_query
      self.class.new(body: body, query: yield(query))
    end

    # @api public
    # Transforms only the body.
    #
    # @yield [Hash] the body parameters
    # @return [Request] the transformed request
    #
    # @example
    #   request.transform_body { |body| prepare(body) }
    def transform_body
      self.class.new(body: yield(body), query: query)
    end
  end
end
