# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      module Record
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
              @response.reference type_name, to: type_name

              @capabilities.each do |capability|
                capability.record_response_types(@response, @schema_class)
              end

              @response.object? :meta
            end
          end
        end
      end
    end
  end
end
