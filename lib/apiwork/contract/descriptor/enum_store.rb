# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class EnumStore < Store
        class << self
          def register_enum(name, values, scope: nil, api_class: nil, description: nil, example: nil, deprecated: false)
            register(
              name,
              values,
              scope: scope,
              metadata: {
                values: values,
                description: description,
                example: example,
                deprecated: deprecated
              },
              api_class: api_class
            )
          end

          def serialize(api)
            result = {}

            if api
              storage(api).each_pair.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
                enum_data = {
                  values: metadata[:payload],
                  description: metadata[:description],
                  example: metadata[:example],
                  deprecated: metadata[:deprecated] || false
                }
                result[qualified_name] = enum_data
              end
            end

            result
          end

          protected

          def storage_name
            :enums
          end

          def resolved_value(metadata)
            metadata[:values] || metadata[:payload]
          end
        end
      end
    end
  end
end
