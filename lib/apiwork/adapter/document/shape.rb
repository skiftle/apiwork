# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Base class for document shapes.
      #
      # Subclass to define response type structure for record or collection documents.
      # Access builder and context through reader methods.
      #
      # @example Custom shape
      #   class MyShape < Document::Shape
      #     def build
      #       builder.reference :invoice, to: :invoice
      #       builder.object? :meta
      #     end
      #   end
      class Shape
        class << self
          def build(builder, context)
            new(builder, context).build
          end
        end

        # @api public
        # @return [Object] the response type builder
        attr_reader :builder

        # @api public
        # @return [ShapeContext] the shape context
        attr_reader :context

        def initialize(builder, context)
          @builder = builder
          @context = context
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
