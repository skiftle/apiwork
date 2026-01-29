# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          shape do |shape|
            shape.array(shape.root_key.plural.to_sym) do |array|
              array.reference(shape.data_type)
            end

            shape.object?(:meta)
            shape.merge!(shape.metadata)
          end

          def json
            {
              root_key.plural.to_sym => data,
              meta: meta.presence,
              **metadata,
            }.compact
          end
        end
      end
    end
  end
end
