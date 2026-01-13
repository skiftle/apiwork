# frozen_string_literal: true

module Apiwork
  module ErrorCode
    class Registry < Apiwork::Registry
      class << self
        def register(key, attach_path: false, status:)
          key = normalize_key(key)
          status = Integer(status)

          raise ArgumentError, "Status must be 400-599, got #{status}" unless (400..599).cover?(status)

          store[key] = Definition.new(attach_path:, key:, status:)
        end

        def all
          values
        end
      end
    end
  end
end
