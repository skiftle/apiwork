# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          response_types Document::Types::Responses

          def build_response(collection, additions, meta)
            {
              schema_class.root_key.plural => collection,
              **additions,
              meta: meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
