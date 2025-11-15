# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class EnumStore < Base
        class << self
          def register_local(scope, name, values)
            super(scope, name, values, { values: values })
          end

          def serialize_all_for_api(_api)
            result = {}

            global_storage.sort_by { |enum_name, _| enum_name.to_s }.each do |enum_name, values|
              result[enum_name] = values
            end

            local_storage.to_a.sort_by { |scope, _| scope.to_s }.each do |_scope, enums|
              enums.to_a.sort_by { |enum_name, _| enum_name.to_s }.each do |_enum_name, metadata|
                qualified_enum_name = metadata[:qualified_name]
                values = metadata[:values]

                result[qualified_enum_name] = values
              end
            end

            result
          end

          protected

          def storage_name
            :enums
          end

          def extract_payload_value(metadata)
            metadata[:values]
          end
        end
      end
    end
  end
end
