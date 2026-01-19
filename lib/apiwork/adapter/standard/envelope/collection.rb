# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Envelope
        class Collection < Adapter::Envelope::Collection
          def prepare(collection, state)
            { data: collection, metadata: {} }
          end

          def render(result, metadata, state)
            data = result.is_a?(Hash) ? result[:data] : result
            {
              schema_class.root_key.plural => data,
              pagination: metadata[:pagination],
              meta: state.meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
