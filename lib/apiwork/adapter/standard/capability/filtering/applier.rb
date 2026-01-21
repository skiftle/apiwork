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
              return context.data if context.params.blank?

              Filter.apply(context)
            end
          end
        end
      end
    end
  end
end
