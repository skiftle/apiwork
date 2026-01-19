# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Error < Adapter::Envelope::Error
          def render(issues, layer, state)
            {
              layer:,
              issues: issues.map(&:to_h),
            }
          end
        end
      end
    end
  end
end
