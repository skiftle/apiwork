# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          shape do |object, context|
            root_key = context.schema_class.root_key

            object.array root_key.plural.to_sym do
              reference root_key.singular.to_sym
            end

            context.capability_shapes.each_value { |shape| object.merge!(shape) }
            object.object? :meta
          end

          def build
            {
              schema_class.root_key.plural => data,
              **additions,
              meta: meta.presence,
            }.compact
          end
        end
      end
    end
  end
end
