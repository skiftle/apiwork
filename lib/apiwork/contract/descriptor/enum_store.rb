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

            # Serialize from unified storage
            if api
              storage(api).to_a.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
                # metadata structure: { short_name:, qualified_name:, scope:, payload:, values: }
                values = metadata[:values] || metadata[:payload]
                result[qualified_name] = values
              end
            end

            # Legacy fallback: include API-scoped global enums
            if api
              api_storage(api).sort_by { |enum_name, _| enum_name.to_s }.each do |enum_name, values|
                next if result.key?(enum_name) # Unified storage takes precedence

                result[enum_name] = values
              end
            end

            # Legacy fallback: include truly global enums
            global_storage.sort_by { |enum_name, _| enum_name.to_s }.each do |enum_name, values|
              next if result.key?(enum_name)

              result[enum_name] = values
            end

            # Legacy fallback: include API-scoped local enums
            if api
              api_local_storage(api).to_a.sort_by { |scope, _| scope.to_s }.each do |_scope, enums|
                enums.to_a.sort_by { |enum_name, _| enum_name.to_s }.each do |_enum_name, metadata|
                  qualified_enum_name = metadata[:qualified_name]
                  next if result.key?(qualified_enum_name)

                  values = metadata[:values]
                  result[qualified_enum_name] = values
                end
              end
            end

            # Legacy fallback: include local enums
            local_storage.to_a.sort_by { |scope, _| scope.to_s }.each do |_scope, enums|
              enums.to_a.sort_by { |enum_name, _| enum_name.to_s }.each do |_enum_name, metadata|
                qualified_enum_name = metadata[:qualified_name]
                next if result.key?(qualified_enum_name)

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
