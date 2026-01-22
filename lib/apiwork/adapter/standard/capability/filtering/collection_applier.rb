# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class CollectionApplier < Adapter::Capability::CollectionApplier::Base
            def apply
              filter_params = request.query[:filter]
              return result(collection:) if filter_params.blank?

              includes = IncludesResolver::AssociationExtractor.new(schema_class).extract_from_filter(filter_params).keys
              filtered = Filter.apply(collection, filter_params, schema_class)

              result(includes:, collection: filtered)
            end
          end
        end
      end
    end
  end
end
