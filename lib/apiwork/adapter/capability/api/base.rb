# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        # @api public
        # Base class for capability API builders.
        #
        # Provides access to capability options and aggregated configuration
        # across all representations.
        class Base < Builder::API::Base
          # @api public
          # @return [Configuration] capability options for this builder
          attr_reader :options

          def initialize(api_class, capability_name: nil, options: nil)
            super(api_class)
            @capability_name = capability_name
            @options = options
          end

          # @api public
          # Returns all unique values for a configuration key across all representations.
          #
          # Use this to check which options are used by any representation
          # when building API-level schemas.
          #
          # @param key [Symbol] the configuration key to look up
          # @return [Set] unique values from all representations
          #
          # @example Check if any representation uses cursor pagination
          #   if configured(:strategy).include?(:cursor)
          #     # build cursor pagination schema
          #   end
          def configured(key)
            api_class.representation_registry.options_for(@capability_name, key)
          end
        end
      end
    end
  end
end
