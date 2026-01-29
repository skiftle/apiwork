# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        class Default < Base
          data_type :error
          api_builder APIBuilder

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
