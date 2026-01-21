# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Applier
        # @api public
        # Base class for capability appliers.
        #
        # Subclass to implement runtime behavior for a capability.
        # Handles data transformation during request processing.
        #
        # @example Custom applier
        #   class MyCapability::Applier < Capability::Applier::Base
        #     def extract
        #       context.request.query[:my_param] || {}
        #     end
        #
        #     def apply
        #       transform(context.data, context.params)
        #     end
        #   end
        class Base
          # @api public
          # @return [Configuration] the capability configuration
          attr_reader :config

          # @api public
          # @return [ApplierContext] the execution context
          attr_reader :context

          def initialize(config, context)
            @config = config
            @context = context
          end

          # @api public
          # Extracts parameters from the request.
          #
          # @return [Hash] extracted parameters
          def extract
            {}
          end

          # @api public
          # Returns associations to preload.
          #
          # @return [Array<Symbol>] association names to preload
          def includes
            []
          end

          # @api public
          # Transforms the data.
          #
          # @return [Object] the transformed data
          def apply
            context.data
          end

          # @api public
          # Returns serialization options.
          #
          # @return [Hash] serialization options
          def serialize_options
            {}
          end
        end
      end
    end
  end
end
