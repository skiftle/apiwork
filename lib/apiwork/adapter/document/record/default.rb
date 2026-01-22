# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape do |object, context|
            object.reference context.schema_class.root_key.singular.to_sym
            context.capability_shapes.each_value { |shape| object.merge!(shape) }
            object.object? :meta
          end

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
