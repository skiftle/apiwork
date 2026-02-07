# frozen_string_literal: true

module Apiwork
  module Introspection
    class Action
      # @api public
      # Wraps action response definitions.
      #
      # @example Response with body
      #   response = action.response
      #   response.body?        # => true
      #   response.no_content?  # => false
      #   response.body         # => Param for response body
      #
      # @example No content response
      #   response.no_content?  # => true
      #   response.body?        # => false
      class Response
        def initialize(dump)
          @dump = dump
        end

        # @api public
        # Response body definition.
        # @return [Param, nil]
        # @see Param
        def body
          @body ||= @dump[:body] ? Param.build(@dump[:body]) : nil
        end

        # @api public
        # Whether this is a no-content response (204).
        # @return [Boolean]
        def no_content?
          @dump[:no_content]
        end

        # @api public
        # Whether a body is defined.
        # @return [Boolean]
        def body?
          body.present?
        end

        # @api public
        # Structured representation.
        # @return [Hash]
        def to_h
          { body: body&.to_h, no_content: no_content? }
        end
      end
    end
  end
end
