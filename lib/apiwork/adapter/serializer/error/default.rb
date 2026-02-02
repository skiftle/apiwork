# frozen_string_literal: true

module Apiwork
  module Adapter
    module Serializer
      module Error
        # @api public
        # Default error serializer.
        #
        # Serializes errors into a hash with issues array and layer.
        #
        # @example Configuration
        #   class MyAdapter < Adapter::Base
        #     error_serializer Serializer::Error::Default
        #   end
        #
        # @example Output
        #   {
        #     "issues": [{ "code": "invalid", "detail": "...", "path": [...], "pointer": "/..." }],
        #     "layer": "contract"
        #   }
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
