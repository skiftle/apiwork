# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        # @api public
        # Base class for capability Contract phase.
        #
        # Contract phase runs once per bound contract at registration time.
        # Use it to generate contract-specific types based on the representation.
        class Base
          # @api public
          # @return [Array<Symbol>] actions available for this contract
          attr_reader :actions

          # @api public
          # @return [Configuration] capability options
          attr_reader :options

          # @api public
          # @return [Class] the representation class for this contract
          attr_reader :representation_class

          # @!method action(name, &block)
          #   @api public
          #   Defines request/response for an action.
          #   @param name [Symbol] the action name
          #   @yield block defining request and response
          #   @return [void]

          # @!method enum(name, values:)
          #   @api public
          #   Defines an enum type.
          #   @param name [Symbol] the enum name
          #   @param values [Array<String>] allowed values
          #   @return [void]

          # @!method enum?(name)
          #   @api public
          #   Checks if an enum is registered.
          #   @param name [Symbol] the enum name
          #   @return [Boolean] true if enum exists

          # @!method import(name, from:)
          #   @api public
          #   Imports a type from API-level registry.
          #   @param name [Symbol] the local type name
          #   @param from [Symbol] the API-level type name
          #   @return [void]

          # @!method object(name, &block)
          #   @api public
          #   Defines a named object type.
          #   @param name [Symbol] the object name
          #   @yield block defining params
          #   @return [void]

          # @!method type?(name)
          #   @api public
          #   Checks if a type is registered.
          #   @param name [Symbol] the type name
          #   @return [Boolean] true if type exists

          # @!method union(name, &block)
          #   @api public
          #   Defines a union type.
          #   @param name [Symbol] the union name
          #   @yield block defining variants
          #   @return [void]

          # @!method scoped_enum_name(name)
          #   @api public
          #   Returns the scoped name for an enum.
          #   @param name [Symbol] the base enum name
          #   @return [Symbol] the scoped enum name

          # @!method scoped_type_name(name)
          #   @api public
          #   Returns the scoped name for a type.
          #   @param name [Symbol] the base type name
          #   @return [Symbol] the scoped type name

          # @!method find_contract_for_representation(representation_class)
          #   @api public
          #   Finds the contract class for a representation.
          #   @param representation_class [Class] the representation class
          #   @return [Class, nil] the contract class

          # @!method api_class
          #   @api public
          #   Returns the API class for this contract.
          #   @return [Class] the API class

          delegate :action,
                   :api_class,
                   :enum,
                   :enum?,
                   :find_contract_for_representation,
                   :import,
                   :object,
                   :scoped_enum_name,
                   :scoped_type_name,
                   :type?,
                   :union,
                   to: :contract_class

          def initialize(context)
            @contract_class = context.contract_class
            @representation_class = context.representation_class
            @actions = context.actions
            @options = context.options
          end

          # @api public
          # Builds contract-level types for this capability.
          #
          # Override this method to generate types based on the representation.
          # @return [void]
          def build
            raise NotImplementedError
          end

          private

          attr_reader :contract_class
        end
      end
    end
  end
end
