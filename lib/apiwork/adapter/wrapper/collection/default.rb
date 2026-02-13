# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      module Collection
        # @api public
        # Default collection response wrapper.
        #
        # Wraps serialized records under a pluralized root key with optional meta and capability metadata.
        #
        # @example Configuration
        #   class MyAdapter < Adapter::Base
        #     collection_wrapper Wrapper::Collection::Default
        #   end
        #
        # @example Output
        #   {
        #     "invoices": [
        #       { "id": 1, "number": "INV-001" },
        #       { "id": 2, "number": "INV-002" }
        #     ],
        #     "meta": { ... },
        #     "pagination": { "current": 1, "total": 5 }
        #   }
        class Default < Base
          shape do
            array(root_key.plural.to_sym) do |array|
              array.reference(data_type)
            end

            object?(:meta)
            merge_metadata
          end

          def wrap
            {
              root_key.plural.to_sym => data,
              meta: meta.presence,
              **metadata,
            }.compact
          end
        end
      end
    end
  end
end
