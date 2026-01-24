# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        # @api public
        # Base class for capability Contract phase.
        #
        # Contract phase runs once per bound contract at registration time.
        # Use it to generate contract-specific types based on the schema.
        class Base
          # @api public
          # @return [Array<Symbol>] actions available for this contract
          attr_reader :actions

          # @api public
          # @return [Configuration] capability options
          attr_reader :options

          # @api public
          # @return [Class] the schema class for this contract
          attr_reader :schema_class

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

          # @!method find_contract_for_schema(schema_class)
          #   @api public
          #   Finds the contract class for a schema.
          #   @param schema_class [Class] the schema class
          #   @return [Class, nil] the contract class

          delegate :action,
                   :enum,
                   :find_contract_for_schema,
                   :import,
                   :object,
                   :scoped_enum_name,
                   :scoped_type_name,
                   :type?,
                   :union,
                   to: :registrar

          def initialize(context)
            @registrar = context.registrar
            @schema_class = context.schema_class
            @actions = context.actions
            @options = context.options
          end

          # @api public
          # Builds contract-level types for this capability.
          #
          # Override this method to generate types based on the schema.
          # @return [void]
          def build
            raise NotImplementedError
          end

          # @api public
          # Access to API-level type checking.
          #
          # @return [API::Base] API context for type lookups
          def api
            @api ||= begin
              context = API::Context.new(capabilities: nil, registrar: api_registrar)
              API::Base.new(context)
            end
          end

          private

          attr_reader :registrar

          delegate :api_registrar, to: :registrar
        end
      end
    end
  end
end
