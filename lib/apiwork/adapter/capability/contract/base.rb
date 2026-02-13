# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        # @api public
        # Base class for capability Contract phase.
        #
        # Contract phase runs once per contract with representation at registration time.
        # Use it to generate contract-specific types based on the representation.
        class Base < Builder::Contract::Base
          # @!attribute [r] scope
          #   @api public
          #   The scope for this contract.
          #
          #   @return [Scope]
          # @!attribute [r] options
          #   @api public
          #   The options for this contract.
          #
          #   @return [Configuration]
          attr_reader :options,
                      :scope

          delegate :action, to: :@contract_class

          def initialize(contract_class, representation_class, actions, options)
            super(contract_class, representation_class)
            @scope = Scope.new(representation_class, actions)
            @options = options
          end
        end
      end
    end
  end
end
