# frozen_string_literal: true

module Apiwork
  module Contract
    # Resolves Contract classes for controller actions using smart defaults
    #
    # Resolution order:
    # 1. Explicit contract from routing metadata
    # 2. Named contract via convention (PostsController → PostContract)
    # 3. Schema-based contract (PostsController → PostSchema → anonymous contract)
    # 4. Fail with clear error
    class Resolver
      # Main resolve method - called from controller with all context
      #
      # @param controller_class [Class] Controller class
      # @param action [Symbol] Action name (:index, :show, :create, :update, :destroy)
      # @param metadata [Hash, nil] Optional metadata from routing DSL with overrides
      # @option metadata [String] :contract_class_name Override contract class
      # @option metadata [String] :schema_class_name Override schema class (legacy: resource_class_name)
      # @return [Contract::Base] Contract instance
      # @raise [ConfigurationError] If contract not found
      def self.call(controller_class:, action_name:, metadata: nil)
        # 1. Explicit contract from routing metadata
        if metadata&.dig(:contract_class_name)
          contract_class = constantize_safe(metadata[:contract_class_name])
          return contract_class.new if contract_class

          raise ConfigurationError, "Contract #{metadata[:contract_class_name]} not found"
        end

        # 2. Smart default from naming convention
        inferred_class = infer_from_naming_convention(controller_class)
        return inferred_class.new if inferred_class

        # 3. Schema-based contract (auto-derive from schema)
        schema_class = infer_schema_from_controller(controller_class)
        if schema_class
          contract_class = create_anonymous_contract(schema_class)
          return contract_class.new
        end

        # 4. Fail clearly
        raise ConfigurationError,
              "Contract or Schema not found for #{controller_class}##{action_name}. " \
              "Expected #{inferred_contract_name(controller_class)} or #{inferred_schema_name(controller_class)}, " \
              'or specify contract: in routing.'
      end

      # Legacy method for backward compatibility
      def self.resolve(controller_class, action, metadata: nil)
        contract = call(controller_class: controller_class, action_name: action, metadata: metadata)
        contract.class.action_definition(action)
      end

      private_class_method def self.infer_from_naming_convention(controller_class)
        # PostsController → PostContract (singularize)
        contract_name = inferred_contract_name(controller_class)
        constantize_safe(contract_name)
      end

      private_class_method def self.inferred_contract_name(controller_class)
        # Remove 'Controller' suffix, singularize, then add 'Contract'
        # Api::V1::AccountsController → Api::V1::AccountContract
        base_name = controller_class.name.sub(/Controller$/, '')
        parts = base_name.split('::')

        # Singularize only the last part (the resource name)
        parts[-1] = parts[-1].singularize

        "#{parts.join('::')}Contract"
      end

      private_class_method def self.infer_schema_from_controller(controller_class)
        # PostsController → PostSchema (singularize)
        schema_name = inferred_schema_name(controller_class)
        constantize_safe(schema_name)
      end

      private_class_method def self.inferred_schema_name(controller_class)
        # Remove 'Controller' suffix, singularize, then add 'Schema'
        # Api::V1::AccountsController → Api::V1::AccountSchema
        base_name = controller_class.name.sub(/Controller$/, '')
        parts = base_name.split('::')

        # Singularize only the last part (the resource name)
        parts[-1] = parts[-1].singularize

        "#{parts.join('::')}Schema"
      end

      private_class_method def self.create_anonymous_contract(schema_class)
        # Create an anonymous contract class with the schema
        Class.new(Base) do
          schema schema_class
        end
      end

      private_class_method def self.constantize_safe(class_name)
        class_name.constantize
      rescue NameError
        nil
      end
    end
  end
end
