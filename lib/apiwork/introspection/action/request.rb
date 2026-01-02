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
        def initialize(data)
          @data = data
        end

        # @api public
        # @return [Hash{Symbol => Param}] query parameters as Param objects
        # @see Param
        def query
          @query ||= build_params(@data[:query])
        end

        # @api public
        # @return [Hash{Symbol => Param}] body parameters as Param objects
        # @see Param
        def body
          @body ||= build_params(@data[:body])
        end

        # @api public
        # @return [Boolean] whether query parameters are defined
        def query?
          query.any?
        end

        # @api public
        # @return [Boolean] whether body parameters are defined
        def body?
          body.any?
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          {
            body: body.transform_values(&:to_h),
            query: query.transform_values(&:to_h),
          }
        end

        private

        def build_params(hash)
          return {} unless hash

          hash.transform_values { |d| Param.new(d) }
        end
      end
    end
  end
end
