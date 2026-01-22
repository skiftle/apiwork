# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape Shape

          def build
            {
              schema_class.root_key.singular => data,
              **additions,
              meta: meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
