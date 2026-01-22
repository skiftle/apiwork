# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ApiBuilder
        class Base
          attr_reader :capabilities, :options, :registrar

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :registrar

          def initialize(context)
            @registrar = context.registrar
            @capabilities = context.capabilities
            @capability_name = context.capability_name
            @options = context.options
          end

          def build
            raise NotImplementedError
          end

          def configured(key)
            capabilities.options_for(@capability_name, key)
          end
        end
      end
    end
  end
end
