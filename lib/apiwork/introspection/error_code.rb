# frozen_string_literal: true

module Apiwork
  module Introspection
    # @api public
    # Wraps error code definitions.
    #
    # @example
    #   data.error_codes.each do |error_code|
    #     error_code.code         # => :not_found
    #     error_code.status       # => 404
    #     error_code.description  # => "Resource not found"
    #   end
    class ErrorCode
      # @api public
      # @return [Symbol] error code identifier
      attr_reader :code

      def initialize(code, dump)
        @code = code.to_sym
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
          code: code,
          description: description,
          status: status,
        }
      end
    end
  end
end
