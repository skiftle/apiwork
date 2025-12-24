# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Registers contract-scoped types during contract building.
    #
    # Passed to `register_contract_types` in your adapter. Use to define
    # types specific to a resource contract (request/response shapes).
    #
    # @example Register request body type
    #   def register_contract_types(type_registrar, schema_class, actions:)
    #     type_registrar.type :user_input do
    #       param :name, type: :string
    #       param :email, type: :string
    #     end
    #   end
    #
    # @example Define action contracts
    #   def register_contract_types(type_registrar, schema_class, actions:)
    #     type_registrar.define_action :index do
    #       response do
    #         param :users, type: :array, of: :user
    #       end
    #     end
    #   end
    class ContractTypeRegistrar
      def initialize(contract_class)
        @contract_class = contract_class
      end

      # @!method type(name, &block)
      #   @api public
      #   Defines a named type scoped to this contract.
      #   @param name [Symbol] the type name
      #   @yield block defining params
      #   @see Apiwork::Contract::Base.type

      # @!method enum(name, values:)
      #   @api public
      #   Defines an enum type scoped to this contract.
      #   @param name [Symbol] the enum name
      #   @param values [Array<String>] allowed values
      #   @see Apiwork::Contract::Base.enum

      # @!method union(name, &block)
      #   @api public
      #   Defines a union type scoped to this contract.
      #   @param name [Symbol] the union name
      #   @yield block defining variants
      #   @see Apiwork::Contract::Base.union

      # @!method define_action(name, &block)
      #   @api public
      #   Defines an action with query, body, and response.
      #   @param name [Symbol] the action name
      #   @yield block defining request/response
      #   @see Apiwork::Contract::Base.define_action

      # @!method import(type_name, from:)
      #   @api public
      #   Imports a type from another contract or the API.
      #   @param type_name [Symbol] the type to import
      #   @param from [Class] source contract class
      #   @see Apiwork::Contract::Base.import

      # @!method resolve_type(name)
      #   @api public
      #   Checks if a type is registered in this contract.
      #   @param name [Symbol] the type name
      #   @return [Boolean] true if type exists

      # @!method scoped_name(name)
      #   @api public
      #   Returns the fully qualified name for a type in this contract's scope.
      #   @param name [Symbol, nil] the local type name
      #   @return [Symbol] the scoped name

      # @!method find_contract_for_schema(schema_class)
      #   @api public
      #   Finds the contract class for an associated schema.
      #   @param schema_class [Class] the schema class
      #   @return [Class, nil] the contract class

      # @!method imports
      #   @api public
      #   Returns the hash of imported types.
      #   @return [Hash] imported types

      delegate :type, :enum, :union, :define_action, :import, to: :contract_class
      delegate :resolve_type, :scoped_name, :find_contract_for_schema, :imports, to: :contract_class

      # @api public
      # Checks if a type is registered at the API level.
      # @param type_name [Symbol] the type name
      # @return [Boolean] true if type exists
      def api_resolve_type(type_name)
        contract_class.api_class.resolve_type(type_name)
      end

      # @api public
      # Registers a type at the API level (global scope).
      # @param type_name [Symbol] the type name
      # @param options [Hash] type options
      # @yield block defining params
      def api_type(type_name, **options, &block)
        contract_class.api_class.type(type_name, **options, &block)
      end

      # @api public
      # Registers a union at the API level (global scope).
      # @param type_name [Symbol] the union name
      # @yield block defining variants
      def api_union(type_name, &block)
        contract_class.api_class.union(type_name, &block)
      end

      private

      attr_reader :contract_class
    end
  end
end
