# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          shape do |shape|
            root_key = shape.representation_class.root_key

            shape.array(root_key.plural.to_sym) do |element|
              element.reference(root_key.singular.to_sym)
            end

            shape.object?(:meta)
          end

          def json
            {
              representation_class.root_key.plural.to_sym => data,
              meta: meta.presence,
            }
          end
        end
      end
    end
  end
end
