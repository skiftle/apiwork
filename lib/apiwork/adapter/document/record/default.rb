# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
        class Default < Base
          shape do |object, context|
            object.reference context.schema_class.root_key.singular.to_sym

            context.capabilities.each do |capability|
              capability.record_response_types(object, context.schema_class)
            end

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
