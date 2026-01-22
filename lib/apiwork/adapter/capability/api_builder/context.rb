# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module APIBuilder
        class Context
          attr_reader :api_class, :capabilities

          def initialize(api_class:, capabilities:)
            @api_class = api_class
            @capabilities = capabilities
          end
        end
      end
    end
  end
end
