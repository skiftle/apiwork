# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps error code definitions.
    #
    # @example
    #   api.error_codes[:not_found].status      # => 404
    #   api.error_codes[:not_found].description # => "Resource not found"
    class ErrorCode
      def initialize(dump)
        @dump = dump
      end

      # @api public
      # The description for this error code.
      #
      # @return [String, nil]
      def description
        @dump[:description]
      end

      # @api public
      # The status for this error code.
      #
      # @return [Integer]
      def status
        @dump[:status]
      end

      # @api public
      # Converts this error code to a hash.
      #
      # @return [Hash]
      def to_h
        {
          description: description,
          status: status,
        }
      end
    end
  end
end
