# frozen_string_literal: true

module Apiwork
  module ErrorCode
    DEFAULTS = {
      bad_request: 400,
      unauthorized: 401,
      payment_required: 402,
      forbidden: 403,
      not_found: 404,
      method_not_allowed: 405,
      not_acceptable: 406,
      request_timeout: 408,
      conflict: 409,
      gone: 410,
      precondition_failed: 412,
      unsupported_media_type: 415,
      unprocessable_entity: 422,
      locked: 423,
      too_many_requests: 429,
      internal_server_error: 500,
      not_implemented: 501,
      bad_gateway: 502,
      service_unavailable: 503,
      gateway_timeout: 504
    }.freeze

    class << self
      delegate :register, :fetch, :registered?, :all, to: Registry

      def name_for_status(status)
        DEFAULTS.key(status)
      end

      def reset!
        Registry.clear!
        register_defaults!
      end

      private

      def register_defaults!
        DEFAULTS.each { |key, status| register(key, status:) }
      end
    end
  end
end
