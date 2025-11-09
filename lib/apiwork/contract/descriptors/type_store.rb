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

          def resolve(name, contract_class:, scope: nil)
            # If scope provided, use parent-chain resolution (like EnumStore)
            if scope
              # Check local storage for this scope
              return local_storage[scope][name][:definition] if local_storage[scope]&.key?(name)

              # Check parent scope if available
              if scope.respond_to?(:parent_scope) && scope.parent_scope
                return resolve(name, contract_class: contract_class, scope: scope.parent_scope)
              end

              # For Definition instances, check action scope
              if scope.class.name == 'Apiwork::Contract::Definition' && scope.respond_to?(:action_name) && scope.action_name
                action_def = contract_class.action_definition(scope.action_name)
                if action_def && local_storage[action_def]&.key?(name)
                  return local_storage[action_def][name][:definition]
                end
              end
            end

            # Check contract class scope
            if local_storage[contract_class]&.key?(name)
              return local_storage[contract_class][name][:definition]
            end

            # Check global
            global_storage[name]
          end

          def qualified_name(contract_class_or_scope, name)
            # Handle ActionDefinition instances
            if contract_class_or_scope.class.name == 'Apiwork::Contract::ActionDefinition'
              contract_class = contract_class_or_scope.contract_class
              action_name = contract_class_or_scope.action_name
              contract_prefix = extract_contract_prefix(contract_class)
              return :"#{contract_prefix}_#{action_name}_#{name}"
            end

            # Handle Definition instances
            if contract_class_or_scope.class.name == 'Apiwork::Contract::Definition'
              contract_class = contract_class_or_scope.contract_class
              action_name = contract_class_or_scope.action_name
              direction = contract_class_or_scope.direction
              contract_prefix = extract_contract_prefix(contract_class)
              if action_name
                return :"#{contract_prefix}_#{action_name}_#{direction}_#{name}"
              else
                return :"#{contract_prefix}_#{direction}_#{name}"
              end
            end

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

            local_storage.to_a.each do |scope, types|
              # scope can be a Contract class, ActionDefinition, or Definition instance
              # Extract the actual contract class
              actual_contract_class = if scope.respond_to?(:contract_class)
                                        scope.contract_class
                                      else
                                        scope
                                      end

              types.to_a.each do |type_name, metadata|
                qualified_type_name = metadata[:qualified_name]
                definition = metadata[:definition]

                result[qualified_type_name] = expand_type_definition(definition, contract_class: actual_contract_class, type_name: type_name)
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
