# frozen_string_literal: true

module Apiwork
  module Spec
    class Data
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
        attr_reader :code

        def initialize(code, data)
          @code = code.to_sym
          @data = data || {}
        end

        # @api public
        # @return [Integer] HTTP status code (e.g., 422, 404)
        def status
          @data[:status]
        end

        # @api public
        # @return [String, nil] error description
        def description
          @data[:description]
        end
      end
    end
  end
end
