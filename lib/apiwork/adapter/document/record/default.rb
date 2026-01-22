# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          response_types Document::Types::Responses

          def build_response(record, additions, meta)
            {
              schema_class.root_key.singular => record,
              **additions,
              meta: meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
