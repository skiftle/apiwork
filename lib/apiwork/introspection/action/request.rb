# frozen_string_literal: true

module Apiwork
  module Introspection
    class Action
      # @api public
      # Wraps action request definitions.
      #
      # Contains query parameters and/or body parameters.
      #
      # @example
      #   request = action.request
      #   request.query? # => true
      #   request.body? # => false
      #   request.query[:page] # => Param for page param
      class Request
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # The query for this request.
        #
        # @return [Hash{Symbol => Param}]
        def query
          @query ||= @dump[:query].transform_values { |dump| Param.build(dump) }
        end

        # @api public
        # The body for this request.
        #
        # @return [Hash{Symbol => Param}]
        def body
          @body ||= @dump[:body].transform_values { |dump| Param.build(dump) }
        end

        # @api public
        # Whether this request has query parameters.
        #
        # @return [Boolean]
        def query?
          query.any?
        end

        # @api public
        # Whether this request has a body.
        #
        # @return [Boolean]
        def body?
          body.any?
        end

        # @api public
        # Converts this request to a hash.
        #
        # @return [Hash]
        def to_h
          {
            body: body.transform_values(&:to_h),
            query: query.transform_values(&:to_h),
          }
        end
      end
    end
  end
end
