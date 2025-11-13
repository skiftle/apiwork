# frozen_string_literal: true

module Apiwork
  module Contract
    # Resolves Contract classes for controller actions using schema-first approach
    #
    # Resolution order:
    # 1. Schema from metadata → schema.contract (explicit or generated)
    # 2. Explicit contract from metadata (standalone, no schema)
    # 3. Fail with clear error
    class Resolver
      extend Concerns::SafeConstantize

      def self.call(controller_class:, action_name:, metadata: nil)
        # 1. Try schema first (preferred)
        if (schema_class = metadata&.dig(:schema_class))
          # Schema.contract returns explicit contract or generates anonymous
          contract_class = schema_class.contract
          return contract_class.new
        end

        # 2. Try standalone contract (legacy fallback)
        if (contract_class_name = metadata&.dig(:contract_class_name))
          contract_class = constantize_safe(contract_class_name)
          return contract_class.new if contract_class

          raise_contract_not_found_error(contract_class_name)
        end

        # 3. Fail clearly
        raise_configuration_error(controller_class, action_name)
      end

      # Legacy method for backward compatibility
      # Returns ActionDefinition instead of Contract instance
      def self.resolve(controller_class:, action_name:, metadata: nil)
        contract = call(controller_class: controller_class, action_name: action_name, metadata: metadata)
        contract.class.action_definition(action_name)
      end

      private_class_method def self.inferred_schema_name(controller_class)
        # Remove 'Controller' suffix, singularize, then add 'Schema'
        # Api::V1::AccountsController → Api::V1::AccountSchema
        base_name = controller_class.name.sub(/Controller$/, '')
        parts = base_name.split('::')
        parts[-1] = parts[-1].singularize
        "#{parts.join('::')}Schema"
      end

      private_class_method def self.inferred_contract_name(controller_class)
        # Remove 'Controller' suffix, singularize, then add 'Contract'
        # Api::V1::AccountsController → Api::V1::AccountContract
        base_name = controller_class.name.sub(/Controller$/, '')
        parts = base_name.split('::')
        parts[-1] = parts[-1].singularize
        "#{parts.join('::')}Contract"
      end

      private_class_method def self.raise_contract_not_found_error(contract_class_name)
        raise ConfigurationError, "Contract #{contract_class_name} not found"
      end

      private_class_method def self.raise_configuration_error(controller_class, action_name)
        raise ConfigurationError,
              "No schema or contract found for #{controller_class}##{action_name}. " \
              "Expected schema: #{inferred_schema_name(controller_class)} " \
              "or contract: #{inferred_contract_name(controller_class)}"
      end
    end
  end
end
