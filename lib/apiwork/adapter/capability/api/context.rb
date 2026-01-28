# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        class Context
          attr_reader :api_class,
                      :capability_name,
                      :features,
                      :options

          def initialize(api_class:, capability_name: nil, features:, options: nil)
            @api_class = api_class
            @features = features
            @capability_name = capability_name
            @options = options
          end
        end
      end
    end
  end
end
