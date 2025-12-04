# frozen_string_literal: true

module Apiwork
  module ErrorCode
    DEFAULTS = {
      bad_request: { status: 400 },
      unauthorized: { status: 401 },
      payment_required: { status: 402 },
      forbidden: { status: 403 },
      not_found: { status: 404, attach_path: true },
      method_not_allowed: { status: 405, attach_path: true },
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
      delegate :register, :fetch, :registered?, :all, to: Registry

      def name_for_status(status)
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
