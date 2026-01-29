# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        class Base < Builder::API::Base
          attr_reader :options

          def initialize(api_class, features, capability_name: nil, options: nil)
            super(api_class, features)
            @capability_name = capability_name
            @options = options
          end

          def configured(key)
            features.options_for(@capability_name, key)
          end
        end
      end
    end
  end
end
