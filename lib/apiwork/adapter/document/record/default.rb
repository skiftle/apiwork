# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape do
            reference context.schema_class.root_key.singular.to_sym
            context.capability_shapes.each_value(&method(:merge!))
            object? :meta
          end

          def build
            {
              schema_class.root_key.singular.to_sym => data,
              **additions,
              meta: meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
