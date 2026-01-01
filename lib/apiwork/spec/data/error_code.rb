# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps error code definitions.
      #
      # @example
      #   api.error_codes.each do |error_code|
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

        # @return [Integer] HTTP status code (e.g., 422, 404)
        def status
          @data[:status]
        end

        # @return [String, nil] error description
        def description
          @data[:description]
        end
      end
    end
  end
end
