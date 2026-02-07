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
      #   request.query?              # => true
      #   request.body?               # => false
      #   request.query[:page]        # => Param for page param
      class Request
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # Query parameters.
        # @return [Hash{Symbol => Param}]
        # @see Param
        def query
          @query ||= @dump[:query].transform_values { |dump| Param.build(dump) }
        end

        # @api public
        # Body parameters.
        # @return [Hash{Symbol => Param}]
        # @see Param
        def body
          @body ||= @dump[:body].transform_values { |dump| Param.build(dump) }
        end

        # @api public
        # Whether query parameters are defined.
        # @return [Boolean]
        def query?
          query.any?
        end

        # @api public
        # Whether body parameters are defined.
        # @return [Boolean]
        def body?
          body.any?
        end

        # @api public
        # Structured representation.
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
