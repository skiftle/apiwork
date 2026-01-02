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
        def initialize(data)
          @data = data
        end

        # @api public
        # @return [Param, nil] response body definition
        # @see Param
        def body
          @body ||= @data[:body] ? Param.new(@data[:body]) : nil
        end

        # @api public
        # @return [Boolean] whether this is a no-content response (204)
        def no_content?
          @data[:no_content] == true
        end

        # @api public
        # @return [Boolean] whether a body is defined
        def body?
          body.present?
        end

        # @api public
        # @return [Hash] structured representation
        def to_h
          { body: body&.to_h, no_content: no_content? }
        end
      end
    end
  end
end
