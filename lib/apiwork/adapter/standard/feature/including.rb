# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Including < Adapter::Feature
          feature_name :including

          def apply(data, state)
            data
          end
        end
      end
    end
  end
end
