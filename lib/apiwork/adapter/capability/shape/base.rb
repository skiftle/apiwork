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
        #     def build_shape
        #       reference :my_field, to: :my_type
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
          # @param target [Apiwork::Object] the object to build into
          # @param context [Document::ShapeContext] the shape context
          # @return [void]
          def build(target, context)
            @target = target
            @context = context
            build_shape
          end

          # @api public
          # Override to define the shape.
          #
          # @return [void]
          def build_shape
            raise NotImplementedError
          end

          private

          attr_reader :context, :target

          delegate :array,
                   :array?,
                   :binary,
                   :binary?,
                   :boolean,
                   :boolean?,
                   :date,
                   :date?,
                   :datetime,
                   :datetime?,
                   :decimal,
                   :decimal?,
                   :integer,
                   :integer?,
                   :literal,
                   :merge!,
                   :number,
                   :number?,
                   :object,
                   :object?,
                   :reference,
                   :reference?,
                   :string,
                   :string?,
                   :time,
                   :time?,
                   :union,
                   :union?,
                   :uuid,
                   :uuid?,
                   to: :target
        end
      end
    end
  end
end
