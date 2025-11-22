# frozen_string_literal: true

module Apiwork
  module Descriptor
    class TypeStore < Store
      class << self
        def register_type(name, scope: nil, api_class: nil, description: nil, example: nil, format: nil, deprecated: false, &block)
          register(
            name,
            block,
            scope: scope,
            metadata: {
              definition: block,
              description: description,
              example: example,
              format: format,
              deprecated: deprecated
            },
            api_class: api_class
          )
        end

        def register_union(name, data, scope: nil, api_class: nil)
          register(name, data, scope: scope, metadata: {}, api_class: api_class)
        end

        def clear!
          @storage&.each_value do |api_storage|
            api_storage.each_value do |metadata|
              metadata.delete(:expanded_payload)
            end
          end

          super
        end

        protected

        def storage_name
          :types
        end

        def resolved_value(metadata)
          metadata[:definition]
        end
      end
    end
  end
end
