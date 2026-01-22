# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ContractBuilder
        class Context
          attr_reader :actions, :contract_class, :options, :schema_class

          def initialize(actions:, contract_class:, options:, schema_class:)
            @contract_class = contract_class
            @schema_class = schema_class
            @actions = actions
            @options = options
          end
        end
      end
    end
  end
end
