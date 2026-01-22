# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class CollectionApplier < Adapter::Capability::CollectionApplier::Base
            def apply
              sort_params = request.query[:sort]
              return result(collection:) if sort_params.blank?

              includes = IncludesResolver::AssociationExtractor.new(schema_class).extract_from_sort(sort_params).keys
              sorted = Sort.apply(collection, sort_params, schema_class)

              result(includes:, collection: sorted)
            end
          end
        end
      end
    end
  end
end
