# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      # @api public
      # Context object for API-wide type registration.
      #
      # Passed to ApiTypes#register during API introspection.
      # Used to register global types shared across all contracts.
      #
      # @example Registering a global type
      #   def register(context)
      #     context.registrar.object :offset_pagination do
      #       integer :current
      #       integer :total
      #     end
      #   end
      class ApiTypesContext
        # @api public
        # @return [APIRegistrar] the API type registrar
        attr_reader :registrar

        # @api public
        # @return [Capabilities] adapter capabilities for querying API structure
        attr_reader :capabilities

        def initialize(capabilities:, registrar:)
          @registrar = registrar
          @capabilities = capabilities
        end
      end
    end
  end
end
