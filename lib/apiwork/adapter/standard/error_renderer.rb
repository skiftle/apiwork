# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class ErrorRenderer
        def call(issues, layer, _state)
          {
            layer:,
            issues: issues.map(&:to_h),
          }
        end
      end
    end
  end
end
