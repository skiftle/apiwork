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
        class Base < Builder::Contract::Base
          # @api public
          # @return [Array<Symbol>] actions available for this contract
          attr_reader :actions

          # @api public
          # @return [Configuration] capability options
          attr_reader :options

          # @!method action(name, &block)
          #   @api public
          #   Defines request/response for an action.
          #   @param name [Symbol] the action name
          #   @yield block defining request and response
          #   @return [void]
          delegate :action, to: :contract_class

          def initialize(contract_class, representation_class, actions, options)
            super(contract_class, representation_class)
            @actions = actions
            @options = options
          end
        end
      end
    end
  end
end
