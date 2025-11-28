# frozen_string_literal: true

module Apiwork
  module API
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
