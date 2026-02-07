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
          # @api public
          # Representation and actions.
          # @return [Scope]
          attr_reader :scope

          # @api public
          # Capability options.
          # @return [Configuration]
          attr_reader :options

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
