# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          class Shape < Document::Shape
            def build
              type_name = context.schema_class.root_key.singular.to_sym

              builder.array context.schema_class.root_key.plural.to_sym do
                reference type_name
              end

              context.capabilities.each do |capability|
                capability.collection_response_types(builder, context.schema_class)
              end

              builder.object? :meta
            end
          end
        end
      end
    end
  end
end
