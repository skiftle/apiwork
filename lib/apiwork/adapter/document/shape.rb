# frozen_string_literal: true

module Apiwork
  module Adapter
    module Document
      # @api public
      # Base class for document shapes.
      #
      # Subclass to define response type structure for record or collection documents.
      # The block receives the shape instance with delegated type definition methods
      # and access to root_key and metadata.
      #
      # @example Custom shape class
      #   class MyShape < Document::Shape
      #     def build
      #       reference(:invoice)
      #       object?(:meta)
      #       merge!(metadata)
      #     end
      #   end
      #
      # @example Inline shape block
      #   shape do |shape|
      #     shape.reference(shape.root_key.singular.to_sym)
      #     shape.object?(:meta)
      #     shape.merge!(shape.metadata)
      #   end
      class Shape
        class << self
          def build(target, root_key, capabilities, representation_class, type)
            metadata = build_metadata(capabilities, representation_class, type)
            new(target, root_key, metadata).build
          end

          private

          def build_metadata(capabilities, representation_class, type)
            result = ::Apiwork::API::Object.new
            capabilities.each do |capability|
              shape = capability.shape(representation_class, type)
              result.merge!(shape) if shape
            end
            result
          end
        end

        # @api public
        # @return [API::Object] capability shapes to merge
        attr_reader :metadata

        # @api public
        # @return [RootKey] the root key for the representation
        # @see Representation::RootKey
        attr_reader :root_key

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

        def initialize(target, root_key, metadata)
          @target = target
          @root_key = root_key
          @metadata = metadata
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
