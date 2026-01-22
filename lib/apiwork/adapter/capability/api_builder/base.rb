# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ApiBuilder
        class Base
          attr_reader :capabilities, :registrar

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :registrar

          def initialize(context)
            @registrar = context.registrar
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
