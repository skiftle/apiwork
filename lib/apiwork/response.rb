# frozen_string_literal: true

module Apiwork
  # @api public
  # Immutable value object representing a response.
  #
  # Encapsulates body parameters. Transformations return new instances,
  # preserving immutability.
  #
  # @example Creating a response
  #   response = Response.new(body: { id: 1, title: "Hello" })
  #   response.body  # => { id: 1, title: "Hello" }
  #
  # @example Transforming keys
  #   response.transform { |data| camelize(data) }
  class Response
    # @api public
    # The body for this response.
    #
    # @return [Hash]
    attr_reader :body

    # @api public
    # Creates a new response context.
    #
    # @param body [Hash]
    #   The body parameters.
    def initialize(body:)
      @body = body
    end

    # @api public
    # Transforms the body parameters.
    #
    # @yield [Hash] the body parameters
    # @return [Response]
    #
    # @example
    #   response.transform { |data| camelize(data) }
    def transform
      self.class.new(body: yield(body))
    end

    # @api public
    # Transforms the body parameters.
    #
    # @yield [Hash] the body parameters
    # @return [Response]
    #
    # @example
    #   response.transform_body { |data| camelize(data) }
    def transform_body
      self.class.new(body: yield(body))
    end
  end
end
