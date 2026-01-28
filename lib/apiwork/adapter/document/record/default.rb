# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape do |shape|
            shape.reference(shape.root_key.singular.to_sym)
            shape.object?(:meta)
            shape.merge!(shape.metadata)
          end

          def json
            {
              root_key.singular.to_sym => data,
              meta: meta.presence,
              **metadata,
            }.compact
          end
        end
      end
    end
  end
end
