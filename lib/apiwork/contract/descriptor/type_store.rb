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
            if scope
              # Scoped union
              storage = api_class ? api_local_storage(api_class) : local_storage
              storage[scope] ||= {}
              storage[scope][name] = {
                qualified_name: qualified_name(scope, name),
                data: data
              }
            else
              # Shared union
              storage = api_class ? api_storage(api_class) : global_storage
              storage[name] = data
            end
          end

          def serialize_all_for_api(api)
            result = {}

            # Serialize API-scoped global types
            if api
              api_storage(api).to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, definition_or_data|
                result[type_name] = if definition_or_data.is_a?(Hash)
                                      definition_or_data
                                    else
                                      expand_type_definition(definition_or_data, contract_class: nil, type_name: type_name)
                                    end
              end
            end

            # Fallback: include truly global types (legacy)
            global_storage.to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, definition_or_data|
              next if result.key?(type_name) # API-scoped takes precedence

              result[type_name] = if definition_or_data.is_a?(Hash)
                                    definition_or_data
                                  else
                                    expand_type_definition(definition_or_data, contract_class: nil, type_name: type_name)
                                  end
            end

            # Serialize API-scoped local types
            if api
              api_local_storage(api).to_a.sort_by { |contract_class, _| contract_class.to_s }.each do |contract_class, types|
                types.to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, metadata|
                  qualified_type_name = metadata[:qualified_name]

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

            # Fallback: include legacy local types
            local_storage.to_a.sort_by { |contract_class, _| contract_class.to_s }.each do |contract_class, types|
              types.to_a.sort_by { |type_name, _| type_name.to_s }.each do |type_name, metadata|
                qualified_type_name = metadata[:qualified_name]
                next if result.key?(qualified_type_name) # API-scoped takes precedence

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
