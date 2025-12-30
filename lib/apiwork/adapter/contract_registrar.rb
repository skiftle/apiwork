# frozen_string_literal: true

module Apiwork
  module Adapter
    # @api public
    # Registers contract-scoped types during contract building.
    #
    # Passed to `register_contract` in your adapter. Use to define
    # types specific to a resource contract (request/response shapes).
    #
    # @example Register request body type
    #   def register_contract(registrar, schema_class, actions:)
    #     registrar.type :user_input do
    #       param :name, type: :string
    #       param :email, type: :string
    #     end
    #   end
    #
    # @example Define action contracts
    #   def register_contract(registrar, schema_class, actions:)
    #     registrar.define_action :index do
    #       response do
    #         param :users, type: :array, of: :user
    #       end
    #     end
    #   end
    class ContractRegistrar
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
      #   @return [ActionDefinition] the action definition
      #   @see Apiwork::Contract::Base.define_action

      # @!method import(type_name, from:)
      #   @api public
      #   Imports a type from another contract or the API.
      #   @param type_name [Symbol] the type to import
      #   @param from [Class] a {Contract::Base} subclass
      #   @see Apiwork::Contract::Base.import

      # @!method resolve_type(name)
      #   @api public
      #   Resolves a type registered in this contract.
      #   @param name [Symbol] the type name
      #   @return [Object, nil] the type definition if registered

      # @!method resolve_enum(name)
      #   @api public
      #   Resolves an enum registered in this contract.
      #   @param name [Symbol] the enum name
      #   @return [Array, nil] the enum values if registered

      # @!method scoped_name(name)
      #   @api public
      #   Returns the fully qualified name for a type in this contract's scope.
      #   @param name [Symbol, nil] the local type name
      #   @return [Symbol] the scoped name

      # @!method find_contract_for_schema(schema_class)
      #   @api public
      #   Finds the contract class for an associated schema.
      #   @param schema_class [Class] a {Schema::Base} subclass
      #   @return [Class, nil] a {Contract::Base} subclass if found

      # @!method imports
      #   @api public
      #   Returns the hash of imported types.
      #   @return [Hash] imported types

      delegate :define_action,
               :enum,
               :find_contract_for_schema,
               :import,
               :imports,
               :resolve_enum,
               :resolve_type,
               :scoped_name,
               :type,
               :union,
               to: :contract_class

      # @api public
      # Returns a registrar for API-level types.
      # Use this to define or resolve types at the API scope.
      # @return [Adapter::APIRegistrar] the API registrar
      def api_registrar
        @api_registrar ||= APIRegistrar.new(contract_class.api_class)
      end

      private

      attr_reader :contract_class
    end
  end
end
