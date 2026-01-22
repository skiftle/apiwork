# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Base class for document shapes.
      #
      # Subclass to define response type structure for record or collection documents.
      # Access object and context through reader methods.
      #
      # @example Custom shape
      #   class MyShape < Document::Shape
      #     def build
      #       object.reference :invoice, to: :invoice
      #       object.object? :meta
      #     end
      #   end
      class Shape
        class << self
          def build(object, context)
            new(object, context).build
          end
        end

        # @api public
        # @return [Contract::Object] the response type object
        attr_reader :object

        # @api public
        # @return [ShapeContext] the shape context
        attr_reader :context

        def initialize(object, context)
          @object = object
          @context = context
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
