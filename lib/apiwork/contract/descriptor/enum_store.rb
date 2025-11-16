# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class EnumStore < Store
        class << self
          def register_enum(name, values, scope: nil, api_class: nil)
            register(name, values, scope: scope, metadata: { values: values }, api_class: api_class)
          end

          def serialize(api)
            result = {}

            # Serialize from unified storage
            if api
              storage(api).to_a.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
                result[qualified_name] = metadata[:payload]
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
