# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          shape do
            root_key = context.representation_class.root_key

            array root_key.plural.to_sym do
              reference root_key.singular.to_sym
            end

            object? :meta
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
