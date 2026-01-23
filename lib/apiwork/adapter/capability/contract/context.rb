# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Contract
        class Context
          attr_reader :actions, :options, :registrar, :schema_class

          def initialize(actions:, options:, registrar:, schema_class:)
            @registrar = registrar
            @schema_class = schema_class
            @actions = actions
            @options = options
          end
        end
      end
    end
  end
end
