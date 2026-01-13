# frozen_string_literal: true

module Apiwork
  # @api public
  module ErrorCode
    DEFAULTS = {
      bad_gateway: { status: 502 },
      bad_request: { status: 400 },
      conflict: { status: 409 },
      forbidden: { status: 403 },
      gateway_timeout: { status: 504 },
      gone: { status: 410 },
      internal_server_error: { status: 500 },
      locked: { status: 423 },
      method_not_allowed: { status: 405 },
      not_acceptable: { status: 406 },
      not_found: { attach_path: true, status: 404 },
      not_implemented: { status: 501 },
      payment_required: { status: 402 },
      precondition_failed: { status: 412 },
      request_timeout: { status: 408 },
      service_unavailable: { status: 503 },
      too_many_requests: { status: 429 },
      unauthorized: { status: 401 },
      unprocessable_entity: { status: 422 },
      unsupported_media_type: { status: 415 },
    }.freeze

    class << self
      # @!method find(key)
      #   @api public
      #   Finds an error code by key.
      #   @param key [Symbol] the error code key
      #   @return [ErrorCode::Definition, nil] the error code or nil if not found
      #   @see .find!
      #   @example
      #     Apiwork::ErrorCode.find(:not_found)
      #
      # @!method find!(key)
      #   @api public
      #   Finds an error code by key.
      #   @param key [Symbol] the error code key
      #   @return [ErrorCode::Definition] the error code
      #   @raise [KeyError] if the error code is not found
      #   @see .find
      #   @example
      #     Apiwork::ErrorCode.find!(:not_found)
      #
      # @!method register(key, attach_path: false, status:)
      #   @api public
      #   Registers a custom error code for use in API responses.
      #
      #   Error codes are used with `raises` declarations and `expose_error`
      #   in controllers. Built-in codes (400-504) are pre-registered.
      #
      #   @param key [Symbol] unique identifier for the error code
      #   @param status [Integer] HTTP status code (must be 400-599)
      #   @param attach_path [Boolean] include request path in error response (default: false)
      #   @return [ErrorCode::Definition] the registered error code
      #   @raise [ArgumentError] if status is outside 400-599 range
      #   @see Issue
      #
      #   @example Register custom error code
      #     Apiwork::ErrorCode.register :resource_locked, status: 423
      #
      #   @example With path attachment
      #     Apiwork::ErrorCode.register :not_found, status: 404, attach_path: true
      delegate :clear!,
               :find,
               :find!,
               :keys,
               :register,
               :registered?,
               :values,
               to: Registry

      def key_for_status(status)
        DEFAULTS.find { |_key, config| config[:status] == status }&.first
      end

      def register_defaults!
        DEFAULTS.each { |key, options| register(key, **options) }
      end
    end
  end
end
