# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Collection
        class Default < Base
          class Shape
            class << self
              def build(response, schema_class, capabilities:)
                new(response, schema_class, capabilities).build
              end
            end

            def initialize(response, schema_class, capabilities)
              @response = response
              @schema_class = schema_class
              @capabilities = capabilities
            end

            def build
              type_name = @schema_class.root_key.singular.to_sym

              @response.array @schema_class.root_key.plural.to_sym do
                reference type_name
              end

              @capabilities.each do |capability|
                capability.collection_response_types(@response, @schema_class)
              end

              @response.object? :meta
            end
          end
        end
      end
    end
  end
end
