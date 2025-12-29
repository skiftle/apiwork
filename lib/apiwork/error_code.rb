# frozen_string_literal: true

module Apiwork
  # @api public
  module ErrorCode
    DEFAULTS = {
      bad_request: { status: 400 },
      unauthorized: { status: 401 },
      payment_required: { status: 402 },
      forbidden: { status: 403 },
      not_found: { status: 404, attach_path: true },
      method_not_allowed: { status: 405 },
      not_acceptable: { status: 406 },
      request_timeout: { status: 408 },
      conflict: { status: 409 },
      gone: { status: 410 },
      precondition_failed: { status: 412 },
      unsupported_media_type: { status: 415 },
      unprocessable_entity: { status: 422 },
      locked: { status: 423 },
      too_many_requests: { status: 429 },
      internal_server_error: { status: 500 },
      not_implemented: { status: 501 },
      bad_gateway: { status: 502 },
      service_unavailable: { status: 503 },
      gateway_timeout: { status: 504 }
    }.freeze

    class << self
      delegate :fetch, :registered?, :all, to: Registry

      # @api public
      # Registers a custom error code for use in API responses.
      #
      # Error codes are used with `raises` declarations and `expose_error`
      # in controllers. Built-in codes (400-504) are pre-registered.
      #
      # @param key [Symbol] unique identifier for the error code
      # @param status [Integer] HTTP status code (must be 400-599)
      # @param attach_path [Boolean] include request path in error response (default: false)
      # @return [ErrorCode::Definition] the registered error code
      # @raise [ArgumentError] if status is outside 400-599 range
      #
      # @example Register custom error code
      #   Apiwork::ErrorCode.register :resource_locked, status: 423
      #
      # @example With path attachment
      #   Apiwork::ErrorCode.register :not_found, status: 404, attach_path: true
      def register(key, attach_path: false, status:)
        Registry.register(key, status:, attach_path:)
      end

      def key_for_status(status)
        DEFAULTS.find { |_, config| config[:status] == status }&.first
      end

      def reset!
        Registry.clear!
        register_defaults!
      end

      private

      def register_defaults!
        DEFAULTS.each { |key, options| register(key, **options) }
      end
    end
  end
end
