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
      # @return [Integer] HTTP status code (e.g., 422, 404)
      def status
        @dump[:status]
      end

      # @api public
      # @return [String, nil] error description
      def description
        @dump[:description]
      end

      # @api public
      # @return [Hash] structured representation
      def to_h
        {
          description: description,
          status: status,
        }
      end
    end
  end
end
