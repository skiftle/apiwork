# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        class Default < Base
          types Types

          def serialize(error, context:)
            {
              issues: error.issues.map(&:to_h),
              layer: error.layer,
            }
          end
        end
      end
    end
  end
end
