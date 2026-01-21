# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ContractTypes
        # @api public
        # Base class for contract-specific type registration.
        #
        # Subclass to register types scoped to a specific schema/contract.
        # Called during contract introspection for each schema.
        #
        # @example Custom contract types
        #   class MyCapability::ContractTypes < Capability::ContractTypes::Base
        #     def register(context)
        #       context.registrar.action(:index) do
        #         request do
        #           query do
        #             reference? :my_param, to: :my_type
        #           end
        #         end
        #       end
        #     end
        #   end
        class Base
          # @api public
          # @return [Configuration] the capability configuration
          attr_reader :config

          def initialize(config)
            @config = config
          end

          # @api public
          # Registers contract-specific types.
          #
          # @param context [ContractTypesContext] the context with registrar, schema_class, actions
          # @return [void]
          def register(context); end
        end
      end
    end
  end
end
