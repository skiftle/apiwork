# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ApiBuilder
        class Context
          attr_reader :capabilities, :capability_name, :options, :registrar

          def initialize(capabilities:, capability_name: nil, options: nil, registrar:)
            @registrar = registrar
            @capabilities = capabilities
            @capability_name = capability_name
            @options = options
          end
        end
      end
    end
  end
end
