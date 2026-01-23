# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Result < Adapter::Capability::Result::Base
            def apply
              sort_params = request.query[:sort]
              return result(data:) if sort_params.blank?

              includes = IncludesResolver::AssociationExtractor.new(schema_class).extract_from_sort(sort_params).keys
              sorted = Sort.apply(data, sort_params, schema_class)

              result(includes:, data: sorted)
            end
          end
        end
      end
    end
  end
end
