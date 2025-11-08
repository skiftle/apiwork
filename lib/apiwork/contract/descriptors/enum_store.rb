# frozen_string_literal: true

module Apiwork
  module Contract
    module Descriptors
      class EnumStore < Base
        class << self
          def register_global(name, values)
            super(name, values)
          end

          def register_local(scope, name, values)
            super(scope, name, values, { values: values })
          end

          def resolve(name, scope:)
            if local_storage[scope]&.key?(name)
              return local_storage[scope][name][:values]
            end

            if scope.respond_to?(:parent_scope) && scope.parent_scope
              result = resolve(name, scope: scope.parent_scope)
              return result if result
            end

            if scope.class.name == 'Apiwork::Contract::Definition' && scope.respond_to?(:action_name) && scope.action_name
              contract_class = scope.contract_class
              action_def = contract_class.action_definition(scope.action_name) if contract_class.respond_to?(:action_definition)
              if action_def && local_storage[action_def]&.key?(name)
                return local_storage[action_def][name][:values]
              end
            end

            if scope.respond_to?(:contract_class)
              contract_class = scope.contract_class
              if local_storage[contract_class]&.key?(name)
                return local_storage[contract_class][name][:values]
              end
            end

            global_storage[name]
          end

          def qualified_name(scope, name)
            return name if global?(name)

            if scope.is_a?(Class)
              contract_prefix = extract_contract_prefix(scope)
              return :"#{contract_prefix}_#{name}"
            elsif scope.respond_to?(:contract_class) && scope.respond_to?(:action_name)
              contract_prefix = extract_contract_prefix(scope.contract_class)
              action_name = scope.action_name

              if scope.respond_to?(:direction)
                direction = scope.direction
                return :"#{contract_prefix}_#{action_name}_#{direction}_#{name}"
              else
                return :"#{contract_prefix}_#{action_name}_#{name}"
              end
            else
              name
            end
          end

          def serialize_all_for_api(api)
            result = {}

            global_storage.each do |enum_name, values|
              result[enum_name] = values
            end

            local_storage.to_a.each do |scope, enums|
              enums.to_a.each do |_enum_name, metadata|
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
        end
      end
    end
  end
end
