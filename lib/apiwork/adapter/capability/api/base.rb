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
          # @!attribute [r] scope
          #   @api public
          #   The scope for this API.
          #
          #   @return [Scope]
          # @!attribute [r] options
          #   @api public
          #   The options for this API.
          #
          #   @return [Configuration]
          attr_reader :options,
                      :scope

          def initialize(api_class, capability_name: nil, options: nil)
            super(api_class)
            @capability_name = capability_name
            @scope = Scope.new(api_class)
            @options = options
          end

          # @api public
          # The configured values for a key.
          #
          # @param key [Symbol]
          #   The configuration key.
          # @return [Set]
          #
          # @example Check if any representation uses cursor pagination
          #   if configured(:strategy).include?(:cursor)
          #     # build cursor pagination schema
          #   end
          def configured(key)
            scope.configured(@capability_name, key)
          end
        end
      end
    end
  end
end
