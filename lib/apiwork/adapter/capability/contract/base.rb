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
          attr_reader :options

          delegate :action, to: :contract_class

          def initialize(contract_class, representation_class, actions, options)
            super(contract_class, representation_class, actions:)
            @options = options
          end
        end
      end
    end
  end
end
