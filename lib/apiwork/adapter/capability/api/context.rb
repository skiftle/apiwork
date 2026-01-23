# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        class Context
          attr_reader :capability_name,
                      :features,
                      :options,
                      :registrar

          def initialize(capability_name: nil, features:, options: nil, registrar:)
            @registrar = registrar
            @features = features
            @capability_name = capability_name
            @options = options
          end
        end
      end
    end
  end
end
