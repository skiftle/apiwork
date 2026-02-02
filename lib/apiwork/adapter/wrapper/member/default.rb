# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Member
        # @api public
        # Default member response wrapper.
        #
        # Wraps a serialized record under a singular root key with optional meta and capability metadata.
        #
        # @example Configuration
        #   class MyAdapter < Adapter::Base
        #     member_wrapper Wrapper::Member::Default
        #   end
        #
        # @example Output
        #   {
        #     "invoice": { "id": 1, "number": "INV-001" },
        #     "meta": { ... }
        #   }
        class Default < Base
          shape do
            reference(root_key.singular.to_sym, to: data_type)
            object?(:meta)
            merge_shape!(metadata_shapes)
          end

          def json
            {
              root_key.singular.to_sym => data,
              meta: meta.presence,
              **metadata,
            }.compact
          end
        end
      end
    end
  end
end
