# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps action response definitions.
      #
      # @example Response with body
      #   response = action.response
      #   response.body?        # => true
      #   response.no_content?  # => false
      #   response.body         # => Param for response body
      #   response.body_hash    # => raw hash for mappers
      #
      # @example No content response
      #   response.no_content?  # => true
      #   response.body?        # => false
      class Response
        def initialize(data)
          @data = data || {}
        end

        # @return [Param, nil] response body definition
        # @see Param
        def body
          @body ||= @data[:body] ? Param.new(@data[:body]) : nil
        end

        # @return [Boolean] whether this is a no-content response (204)
        def no_content?
          @data[:no_content] == true
        end

        # @return [Boolean] whether a body is defined
        def body?
          body.present?
        end

        # @return [Hash, nil] raw body hash for mappers that need hash access
        def body_hash
          @data[:body]
        end
      end
    end
  end
end
