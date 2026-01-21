# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      # @api public
      # Context object for contract-specific type registration.
      #
      # Passed to ContractTypes#register during contract introspection.
      # Used to register types scoped to a specific schema/contract.
      #
      # @example Registering contract types
      #   def register(context)
      #     context.registrar.action(:index) do
      #       request do
      #         query do
      #           reference? :page, to: :page_params
      #         end
      #       end
      #     end
      #   end
      class ContractTypesContext
        # @api public
        # @return [ContractRegistrar] the contract type registrar
        attr_reader :registrar

        # @api public
        # @return [Class] the schema class
        attr_reader :schema_class

        # @api public
        # @return [Hash] the actions defined for this contract
        attr_reader :actions

        def initialize(actions:, registrar:, schema_class:)
          @registrar = registrar
          @schema_class = schema_class
          @actions = actions
        end
      end
    end
  end
end
