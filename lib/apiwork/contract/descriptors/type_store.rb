# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class TypeStore < Base
        class << self
          def register_global(name, &block)
            super(name, block)
          end

          def register_local(contract_class, name, &block)
            super(contract_class, name, block, { definition: block })
          end

          def serialize_all_for_api(_api)
            result = {}

            # First pass: expand all type definitions
            global_storage.to_a.each do |type_name, definition|
              result[type_name] = expand_type_definition(definition, contract_class: nil, type_name: type_name)
            end

            local_storage.to_a.each do |contract_class, types|
              types.to_a.each do |type_name, metadata|
                qualified_type_name = metadata[:qualified_name]
                definition = metadata[:definition]

                result[qualified_type_name] = expand_type_definition(
                  definition,
                  contract_class: contract_class,
                  type_name: type_name
                )
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

          # Extract all type references from a type definition
          # @param definition [Hash] Type definition (params hash)
          # @return [Array<Symbol>] Array of referenced type names
          def extract_type_references(definition)
            refs = []

            definition.each_value do |param|
              next unless param.is_a?(Hash)

              # Direct type reference
              refs << param[:type] if param[:type].is_a?(Symbol) && !primitive_type?(param[:type])

              # Array 'of' reference
              refs << param[:of] if param[:of].is_a?(Symbol) && !primitive_type?(param[:of])

              # Union variant references
              if param[:variants].is_a?(Array)
                param[:variants].each do |variant|
                  next unless variant.is_a?(Hash)

                  refs << variant[:type] if variant[:type].is_a?(Symbol) && !primitive_type?(variant[:type])

                  refs << variant[:of] if variant[:of].is_a?(Symbol) && !primitive_type?(variant[:of])

                  # Recursively check nested shape in variants
                  refs.concat(extract_type_references(variant[:shape])) if variant[:shape].is_a?(Hash)
                end
              end

              # Nested shape references (for nested objects)
              refs.concat(extract_type_references(param[:shape])) if param[:shape].is_a?(Hash)
            end

            refs.uniq
          end

          # Check if a type is a primitive (not a custom type reference)
          # @param type [Symbol] Type name to check
          # @return [Boolean] true if type is a primitive
          def primitive_type?(type)
            %i[
              string integer boolean datetime date uuid object array
              decimal float literal union enum
            ].include?(type)
          end
        end
      end
    end
  end
end
