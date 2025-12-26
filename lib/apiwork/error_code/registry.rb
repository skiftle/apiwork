# frozen_string_literal: true

module Apiwork
  module ErrorCode
    class Registry < Apiwork::Registry
      class << self
        def register(key, status:, attach_path: false)
          key = normalize_key(key)
          status = Integer(status)

          raise ArgumentError, "Status must be 400-599, got #{status}" unless (400..599).cover?(status)

          store[key] = Definition.new(key:, status:, attach_path:)
        end

        def all
          keys
        end
      end
    end
  end
end
