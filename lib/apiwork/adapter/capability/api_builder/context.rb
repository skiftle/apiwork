# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ApiBuilder
        class Context
          attr_reader :capabilities, :registrar

          def initialize(capabilities:, registrar:)
            @registrar = registrar
            @capabilities = capabilities
          end
        end
      end
    end
  end
end
