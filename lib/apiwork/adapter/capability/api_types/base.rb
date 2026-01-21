# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ApiTypes
        # @api public
        # Base class for API-wide type registration.
        #
        # Subclass to register global types shared across all contracts.
        # Called once during API introspection.
        #
        # @example Custom API types
        #   class MyCapability::ApiTypes < Capability::ApiTypes::Base
        #     def register(context)
        #       context.registrar.object :my_type do
        #         string :name
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
          # Registers API-wide types.
          #
          # @param context [ApiTypesContext] the context with registrar and capabilities
          # @return [void]
          def register(context); end
        end
      end
    end
  end
end
