# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module APIBuilder
        class Base
          attr_reader :api_class, :capabilities

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :api_class

          def initialize(context)
            @api_class = context.api_class
            @capabilities = context.capabilities
          end

          def build
            raise NotImplementedError
          end
        end
      end
    end
  end
end
