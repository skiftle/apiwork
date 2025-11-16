# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptor
      class TypeStore < Store
        class << self
          def register_type(name, scope: nil, api_class: nil, &block)
            register(name, block, scope: scope, metadata: { definition: block }, api_class: api_class)
          end

          def register_union(name, data, scope: nil, api_class: nil)
            store = storage(api_class)
            qualified = scope ? qualified_name(scope, name) : name

            store[qualified] = {
              short_name: name,
              qualified_name: qualified,
              scope: scope,
              payload: data,
              data: data # Union data stored in both payload and data for compatibility
            }
          end

          def serialize_all_for_api(api)
            result = {}

            # Serialize from unified storage
            if api
              storage(api).to_a.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
                # metadata structure: { short_name:, qualified_name:, scope:, payload:, data:, definition: }
                result[qualified_name] = if metadata[:data]
                                           # Union data
                                           metadata[:data]
                                         elsif metadata[:payload].is_a?(Proc)
                                           # Block definition - expand it
                                           expand_type_definition(
                                             metadata[:payload],
                                             contract_class: metadata[:scope],
                                             type_name: metadata[:short_name]
                                           )
                                         elsif metadata[:payload].is_a?(Hash)
                                           # Already expanded data
                                           metadata[:payload]
                                         else
                                           # Fallback - use metadata[:definition] if available
                                           expand_type_definition(
                                             metadata[:definition] || metadata[:payload],
                                             contract_class: metadata[:scope],
                                             type_name: metadata[:short_name]
                                           )
                                         end
              end
            end

            # Legacy fallback: include old API-scoped global types
            if api
              api_storage(api).to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, definition_or_data|
                next if result.key?(type_name) # Unified storage takes precedence

                result[type_name] = if definition_or_data.is_a?(Hash)
                                      definition_or_data
                                    else
                                      expand_type_definition(definition_or_data, contract_class: nil, type_name: type_name)
                                    end
              end
            end

            # Legacy fallback: include truly global types
            global_storage.to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, definition_or_data|
              next if result.key?(type_name)

              result[type_name] = if definition_or_data.is_a?(Hash)
                                    definition_or_data
                                  else
                                    expand_type_definition(definition_or_data, contract_class: nil, type_name: type_name)
                                  end
            end

            # Legacy fallback: include API-scoped local types
            if api
              api_local_storage(api).to_a.sort_by { |contract_class, _| contract_class.to_s }.each do |contract_class, types|
                types.to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, metadata|
                  qualified_type_name = metadata[:qualified_name]
                  next if result.key?(qualified_type_name)

                  result[qualified_type_name] = if metadata[:data]
                                                  metadata[:data]
                                                elsif metadata[:definition]
                                                  expand_type_definition(
                                                    metadata[:definition],
                                                    contract_class: contract_class,
                                                    type_name: type_name
                                                  )
                                                end
                end
              end
            end

            # Legacy fallback: include local types
            local_storage.to_a.sort_by { |contract_class, _| contract_class.to_s }.each do |contract_class, types|
              types.to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, metadata|
                qualified_type_name = metadata[:qualified_name]
                next if result.key?(qualified_type_name)

                result[qualified_type_name] = if metadata[:data]
                                                metadata[:data]
                                              elsif metadata[:definition]
                                                expand_type_definition(
                                                  metadata[:definition],
                                                  contract_class: contract_class,
                                                  type_name: type_name
                                                )
                                              end
              end
            end

            result
          end

          protected

          def storage_name
            :types
          end

          def extract_payload_value(metadata)
            metadata[:definition]
          end

          private

          def expand_type_definition(definition, contract_class: nil, type_name: nil, scope: nil)
            temp_contract = contract_class || Class.new(Apiwork::Contract::Base)

            temp_definition = Apiwork::Contract::Definition.new(
              type: :input,
              contract_class: temp_contract
            )

            temp_definition.instance_eval(&definition)
            temp_definition.as_json
          end

          def extract_type_references(definition)
            references = []

            definition.each_value do |param|
              next unless param.is_a?(Hash)

              # Direct type reference
              references << param[:type] if param[:type].is_a?(Symbol) && custom_type?(param[:type])

              # Array 'of' reference
              references << param[:of] if param[:of].is_a?(Symbol) && custom_type?(param[:of])

              # Union variant references
              if param[:variants].is_a?(Array)
                param[:variants].each do |variant|
                  next unless variant.is_a?(Hash)

                  references << variant[:type] if variant[:type].is_a?(Symbol) && custom_type?(variant[:type])

                  references << variant[:of] if variant[:of].is_a?(Symbol) && custom_type?(variant[:of])

                  # Recursively check nested shape in variants
                  references.concat(extract_type_references(variant[:shape])) if variant[:shape].is_a?(Hash)
                end
              end

              # Nested shape references (for nested objects)
              references.concat(extract_type_references(param[:shape])) if param[:shape].is_a?(Hash)
            end

            references.uniq
          end

          def primitive_type?(type)
            %i[
              string integer boolean datetime date uuid object array
              decimal float literal union enum
            ].include?(type)
          end

          def custom_type?(type)
            !primitive_type?(type)
          end
        end
      end
    end
  end
end
