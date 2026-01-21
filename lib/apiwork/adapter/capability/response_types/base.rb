# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module ResponseTypes
        # @api public
        # Base class for response type registration.
        #
        # Subclass to add fields to response types.
        # Called during response type building for collections and records.
        #
        # @example Custom response types
        #   class MyCapability::ResponseTypes < Capability::ResponseTypes::Base
        #     def collection(context)
        #       context.response.reference :my_field, to: :my_type
        #     end
        #   end
        class Base
          # @api public
          # @return [Configuration] the capability configuration
          attr_reader :config

          def initialize(config)
            @config = config
          end

          # @api public
          # Adds fields to collection response types.
          #
          # @param context [ResponseTypesContext] the context with response and schema_class
          # @return [void]
          def collection(context); end

          # @api public
          # Adds fields to record response types.
          #
          # @param context [ResponseTypesContext] the context with response and schema_class
          # @return [void]
          def record(context); end
        end
      end
    end
  end
end
