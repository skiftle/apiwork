# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Base class for document shapes.
      #
      # Subclass to define response type structure for record or collection documents.
      # The block is evaluated in the context of a {ShapeBuilder}, providing direct
      # access to type definition methods and context.
      #
      # @example Custom shape class
      #   class MyShape < Document::Shape
      #     def build
      #       reference :invoice
      #       object? :meta
      #     end
      #   end
      #
      # @example Inline shape block
      #   shape do
      #     reference context.schema_class.root_key.singular.to_sym
      #     object? :meta
      #   end
      class Shape
        class << self
          def build(target, context)
            new(target, context).build
            merge_capability_shapes(target, context)
          end

          private

          def merge_capability_shapes(target, context)
            context.capability_shapes.each_value do |shape|
              target.merge!(shape)
            end
          end
        end

        # @api public
        # @return [ShapeContext] the shape context
        attr_reader :context

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

        def initialize(target, context)
          @target = target
          @context = context
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
