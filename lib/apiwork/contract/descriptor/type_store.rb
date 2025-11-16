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
            register(name, data, scope: scope, metadata: {}, api_class: api_class)
          end

          def serialize(api)
            result = {}

            # Serialize from unified storage
            if api
              storage(api).to_a.sort_by { |qualified_name, _| qualified_name.to_s }.each do |qualified_name, metadata|
                result[qualified_name] = if metadata[:payload].is_a?(Hash)
                                           # Union or already expanded data
                                           metadata[:payload]
                                         elsif metadata[:payload].is_a?(Proc)
                                           # Block definition - expand it
                                           expand_type_definition(
                                             metadata[:payload],
                                             contract_class: metadata[:scope],
                                             type_name: metadata[:name]
                                           )
                                         else
                                           # Fallback - use metadata[:definition] if available
                                           expand_type_definition(
                                             metadata[:definition] || metadata[:payload],
                                             contract_class: metadata[:scope],
                                             type_name: metadata[:name]
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

          def resolved_value(metadata)
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
