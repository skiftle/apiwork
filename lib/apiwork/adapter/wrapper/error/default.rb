# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Error
        # @api public
        # Default error response wrapper.
        #
        # Passes serialized error data through unchanged.
        #
        # @example Configuration
        #   class MyAdapter < Adapter::Base
        #     error_wrapper Wrapper::Error::Default
        #   end
        #
        # @example Output
        #   {
        #     "issues": [{ "code": "blank", "detail": "can't be blank", ... }],
        #     "layer": "domain"
        #   }
        class Default < Base
          shape do
            extends(data_type)
          end

          def json
            data
          end
        end
      end
    end
  end
end
