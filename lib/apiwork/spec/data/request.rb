# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
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
      #   request.query_hash          # => raw hash for mappers
      class Request
        def initialize(data)
          @data = data || {}
        end

        # @return [Hash{Symbol => Param}] query parameters as Param objects
        def query
          @query ||= build_params(@data[:query])
        end

        # @return [Hash{Symbol => Param}] body parameters as Param objects
        def body
          @body ||= build_params(@data[:body])
        end

        # @return [Boolean] whether query parameters are defined
        def query?
          query.any?
        end

        # @return [Boolean] whether body parameters are defined
        def body?
          body.any?
        end

        # @return [Hash] raw query hash for mappers that need hash access
        def query_hash
          @data[:query] || {}
        end

        # @return [Hash] raw body hash for mappers that need hash access
        def body_hash
          @data[:body] || {}
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
