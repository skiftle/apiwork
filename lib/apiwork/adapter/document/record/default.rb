# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape do
            reference context.schema_class.root_key.singular.to_sym
            object? :meta
          end

          def json
            {
              schema_class.root_key.singular.to_sym => data,
              meta: meta.presence,
            }
          end
        end
      end
    end
  end
end
