# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Sorting
          class Applier < Adapter::Capability::Applier::Base
            def extract
              context.request.query[:sort]
            end

            def includes
              return [] if context.params.blank?

              IncludesResolver::AssociationExtractor.new(context.schema_class).extract_from_sort(context.params).keys
            end

            def apply
              Adapter::Capability::ApplyResult.new(data: Sort.apply(context))
            end
          end
        end
      end
    end
  end
end
