# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module API
        # @api public
        # Base class for capability API phase.
        #
        # API phase runs once per API at initialization time.
        # Use it to register shared types used across all contracts.
        class Base
          # @api public
          # @return [Features] feature detection for the API
          attr_reader :features

          # @api public
          # @return [Configuration] capability options
          attr_reader :options

          # @!method enum(name, values:)
          #   @api public
          #   Defines an enum type.
          #   @param name [Symbol] the enum name
          #   @param values [Array<String>] allowed values
          #   @return [void]

          # @!method enum?(name)
          #   @api public
          #   Checks if an enum is registered.
          #   @param name [Symbol] the enum name
          #   @return [Boolean] true if enum exists

          # @!method object(name, &block)
          #   @api public
          #   Defines a named object type.
          #   @param name [Symbol] the object name
          #   @yield block defining params
          #   @return [void]

          # @!method type?(name)
          #   @api public
          #   Checks if a type is registered.
          #   @param name [Symbol] the type name
          #   @return [Boolean] true if type exists

          # @!method union(name, &block)
          #   @api public
          #   Defines a union type.
          #   @param name [Symbol] the union name
          #   @yield block defining variants
          #   @return [void]

          delegate :enum,
                   :enum?,
                   :object,
                   :type?,
                   :union,
                   to: :registrar

          def initialize(context)
            @registrar = context.registrar
            @features = context.features
            @capability_name = context.capability_name
            @options = context.options
          end

          # @api public
          # Builds API-level types for this capability.
          #
          # Override this method to register shared types.
          # @return [void]
          def build
            raise NotImplementedError
          end

          # @api public
          # Returns configured options for a specific key.
          #
          # @param key [Symbol] the option key
          # @return [Object] the configured value
          def configured(key)
            features.options_for(@capability_name, key)
          end

          private

          attr_reader :registrar
        end
      end
    end
  end
end
