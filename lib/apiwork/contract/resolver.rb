# frozen_string_literal: true

module Apiwork
  module Contract
    # Resolves Contract classes for controller actions
    # Finds multi-action contracts and returns the ActionDefinition for the specific action
    class Resolver
      # Main resolve method - called from controller with all context
      #
      # @param controller_class [Class] Controller class
      # @param action [Symbol] Action name (:index, :show, :create, :update, :destroy)
      # @param metadata [Hash, nil] Optional metadata from routing DSL with overrides
      # @option metadata [String] :contract_class_name Override contract class
      # @option metadata [String] :resource_class_name Override resource class
      # @return [ActionDefinition, nil] ActionDefinition for the action or nil
      def self.resolve(controller_class, action, metadata: nil)
        # Priority: metadata contract_class_name > metadata resource_class_name > default resolution

        # 1. Check for explicit contract_class_name in metadata
        if metadata&.dig(:contract_class_name)
          contract_class = resolve_class(metadata[:contract_class_name])
          action_def = contract_class.action_definition(action)
          return action_def if action_def
        end

        # 2. Check for resource_class_name in metadata - build contract from it
        if metadata&.dig(:resource_class_name)
          resource_class = resolve_class(metadata[:resource_class_name])
          return Generator.generate_action(resource_class, action)
        end

        # 3. Default resolution - try to find explicit multi-action contract
        contract_class = find_contract(controller_class)

        # If contract exists, let it handle action_definition (will auto-generate if needed)
        if contract_class
          action_def = contract_class.action_definition(action)
          return action_def if action_def
        end

        # 4. No contract found - try to generate from resource class
        resource_class = Resource::Resolver.from_controller(controller_class)
        return Generator.generate_action(resource_class, action) if resource_class

        nil
      end

      # Find multi-action Contract class
      #
      # @param controller_class [Class] Controller class
      # @return [Class, nil] Contract class or nil
      def self.find_contract(controller_class)
        contract_class_name = build_contract_name(controller_class)

        contract_class_name.constantize
      rescue NameError
        nil
      end

      private

      # Resolve class from string or return class if already a class
      #
      # @param class_or_string [String, Class] Class name or class
      # @return [Class] Resolved class
      def self.resolve_class(class_or_string)
        return class_or_string if class_or_string.is_a?(Class)

        class_or_string.constantize
      end

      # Build contract class name from controller (without action suffix)
      #
      # Examples:
      # - Api::V1::AccountsController → Api::V1::AccountContract
      # - Api::V1::ServicesController → Api::V1::ServiceContract
      #
      # @param controller_class [Class] Controller class
      # @return [String] Contract class name
      def self.build_contract_name(controller_class)
        # Get namespace from controller (Api::V1)
        namespace = controller_class.name.deconstantize

        # Get model name from controller
        # Api::V1::AccountsController → Account
        controller_base_name = controller_class.name.demodulize
                                             .sub(/Controller$/, '')
                                             .singularize

        # Build contract name (no action suffix for multi-action)
        "#{namespace}::#{controller_base_name}Contract"
      end
    end
  end
end
