# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        class Context
          attr_reader :actions, :options, :registrar, :representation_class

          def initialize(actions:, options:, registrar:, representation_class:)
            @registrar = registrar
            @representation_class = representation_class
            @actions = actions
            @options = options
          end
        end
      end
    end
  end
end
