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

          def resolve(name, contract_class:)
            if local_storage[contract_class]&.key?(name)
              return local_storage[contract_class][name][:definition]
            end

            global_storage[name]
          end

          def qualified_name(contract_class_or_scope, name)
            contract_class = if contract_class_or_scope.respond_to?(:contract_class)
                              contract_class_or_scope.contract_class
                            else
                              contract_class_or_scope
                            end

            return name if global?(name)

            contract_prefix = extract_contract_prefix(contract_class)
            return contract_prefix.to_sym if name.nil? || name.to_s.empty?

            :"#{contract_prefix}_#{name}"
          end

          def serialize_all_for_api(api)
            result = {}

            global_storage.to_a.each do |type_name, definition|
              result[type_name] = expand_type_definition(definition, contract_class: nil, type_name: type_name)
            end

            local_storage.to_a.each do |contract_class, types|
              types.to_a.each do |type_name, metadata|
                qualified_type_name = metadata[:qualified_name]
                definition = metadata[:definition]

                result[qualified_type_name] = expand_type_definition(definition, contract_class: contract_class, type_name: type_name)
              end
            end

            result
          end

          protected

          def storage_name
            :types
          end

          private

          def expand_type_definition(definition, contract_class: nil, type_name: nil)
            temp_contract = contract_class || Class.new(Apiwork::Contract::Base)
            temp_definition = Apiwork::Contract::Definition.new(:input, temp_contract)

            temp_definition.instance_eval(&definition)
            temp_definition.as_json
          end
        end
      end
    end
  end
end
