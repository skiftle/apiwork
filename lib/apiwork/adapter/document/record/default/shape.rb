# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          class Shape < Document::Shape
            def build
              type_name = context.schema_class.root_key.singular.to_sym
              builder.reference type_name, to: type_name

              context.capabilities.each do |capability|
                capability.record_response_types(builder, context.schema_class)
              end

              builder.object? :meta
            end
          end
        end
      end
    end
  end
end
