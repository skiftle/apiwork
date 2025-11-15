# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class EnumStore < Store
        class << self
          def register_enum(name, values, scope: nil, api_class: nil)
            register(name, values, scope: scope, metadata: { values: values }, api_class: api_class)
          end

          def serialize_all_for_api(api)
            result = {}

            # Serialize API-scoped global enums
            if api
              api_storage(api).sort_by { |enum_name, _| enum_name.to_s }.each do |enum_name, values|
                result[enum_name] = values
              end
            end

            # Fallback: include truly global enums (legacy)
            global_storage.sort_by { |enum_name, _| enum_name.to_s }.each do |enum_name, values|
              next if result.key?(enum_name) # API-scoped takes precedence

              result[enum_name] = values
            end

            # Serialize API-scoped local enums
            if api
              api_local_storage(api).to_a.sort_by { |scope, _| scope.to_s }.each do |_scope, enums|
                enums.to_a.sort_by { |enum_name, _| enum_name.to_s }.each do |_enum_name, metadata|
                  qualified_enum_name = metadata[:qualified_name]
                  values = metadata[:values]

                  result[qualified_enum_name] = values
                end
              end
            end

            # Fallback: include legacy local enums
            local_storage.to_a.sort_by { |scope, _| scope.to_s }.each do |_scope, enums|
              enums.to_a.sort_by { |enum_name, _| enum_name.to_s }.each do |_enum_name, metadata|
                qualified_enum_name = metadata[:qualified_name]
                next if result.key?(qualified_enum_name) # API-scoped takes precedence

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
