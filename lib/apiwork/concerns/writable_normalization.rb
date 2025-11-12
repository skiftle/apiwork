# frozen_string_literal: true

module Apiwork
  module Concerns
    # Shared module for normalizing writable option across attributes and associations
    module WritableNormalization
      private

      def normalize_writable(value)
        case value
        when true then { on: %i[create update] }
        when false then { on: [] }
        when Hash then { on: Array(value[:on] || %i[create update]) }
        else { on: [] }
        end
      end
    end
  end
end
