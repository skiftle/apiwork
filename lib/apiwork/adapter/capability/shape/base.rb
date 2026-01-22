# frozen_string_literal: true

module Apiwork
  module Adapter
    module Capability
      module Shape
        # @api public
        # Base class for capability shape building.
        #
        # Subclass to define response shape contributions for a capability.
        # The shape is merged into the document response type.
        #
        # @example Custom shape
        #   class MyCapability::Shape < Capability::Shape::Base
        #     def build(object, context)
        #       object.reference :my_field, to: :my_type
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
          # Builds the shape into the given object.
          #
          # @param object [Apiwork::Object] the object to build into
          # @param context [Document::ShapeContext] the shape context
          # @return [void]
          def build(object, context)
            raise NotImplementedError
          end
        end
      end
    end
  end
end
