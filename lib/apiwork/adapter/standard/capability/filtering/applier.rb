# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Applier < Adapter::Capability::Applier::Base
            def extract
              context.request.query[:filter] || {}
            end

            def includes
              return [] if context.params.blank?

              IncludesResolver::AssociationExtractor.new(context.schema_class).extract_from_filter(context.params).keys
            end

            def apply
              data = context.params.blank? ? context.data : Filter.apply(context)
              Adapter::Capability::ApplyResult.new(data:)
            end
          end
        end
      end
    end
  end
end
