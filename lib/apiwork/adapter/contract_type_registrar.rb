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
      # @api public
      # @return [Class] the contract class being configured
      attr_reader :contract_class

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

      delegate :type, :enum, :union, :define_action, :import, to: :contract_class
    end
  end
end
