# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Base class for document shapes.
      #
      # Subclass to define response type structure for record or collection documents.
      # The block receives the shape instance with delegated type definition methods
      # and access to representation_class.
      #
      # @example Custom shape class
      #   class MyShape < Document::Shape
      #     def build
      #       reference(:invoice)
      #       object?(:meta)
      #     end
      #   end
      #
      # @example Inline shape block
      #   shape do |shape|
      #     shape.reference(shape.representation_class.root_key.singular.to_sym)
      #     shape.object?(:meta)
      #   end
      class Shape
        class << self
          def build(target, representation_class, capabilities, type)
            new(target, representation_class).build
            merge_capability_shapes(target, representation_class, capabilities, type)
          end

          private

          def merge_capability_shapes(target, representation_class, capabilities, type)
            capabilities.each do |capability|
              shape = capability.shape(representation_class, type)
              target.merge!(shape) if shape
            end
          end
        end

        # @api public
        # @return [Class] the representation class
        attr_reader :representation_class

        attr_reader :target

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

        def initialize(target, representation_class)
          @target = target
          @representation_class = representation_class
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
