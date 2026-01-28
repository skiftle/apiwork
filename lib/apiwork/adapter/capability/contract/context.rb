# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        class Context
          attr_reader :actions,
                      :contract_class,
                      :options,
                      :representation_class

          def initialize(actions:, contract_class:, options:, representation_class:)
            @contract_class = contract_class
            @representation_class = representation_class
            @actions = actions
            @options = options
          end
        end
      end
    end
  end
end
