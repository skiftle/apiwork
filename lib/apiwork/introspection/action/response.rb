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
        # The body for this response.
        #
        # @return [Param, nil]
        def body
          @body ||= @dump[:body] ? Param.build(@dump[:body]) : nil
        end

        # @api public
        # @return [Boolean]
        def no_content?
          @dump[:no_content]
        end

        # @api public
        # @return [Boolean]
        def body?
          body.present?
        end

        # @api public
        # Converts this response to a hash.
        #
        # @return [Hash]
        def to_h
          { body: body&.to_h, no_content: no_content? }
        end
      end
    end
  end
end
