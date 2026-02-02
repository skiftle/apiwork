# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      # @api public
      # Base class for wrapper shapes.
      #
      # Subclass to define response type structure for record or collection wrappers.
      # The block is evaluated via instance_exec, providing access to type DSL methods
      # and helpers like root_key and metadata_shapes.
      #
      # @example Custom shape class
      #   class MyShape < Wrapper::Shape
      #     def build
      #       reference(:invoice)
      #       object?(:meta)
      #       merge_shape!(metadata_shapes)
      #     end
      #   end
      #
      # @example Inline shape block
      #   shape do
      #     reference(root_key.singular.to_sym)
      #     object?(:meta)
      #     merge_shape!(metadata_shapes)
      #   end
      class Shape
        class << self
          def build(target, root_key, capabilities, representation_class, type, data_type: nil)
            metadata_shapes = build_metadata_shapes(capabilities, representation_class, type)
            new(target, root_key, metadata_shapes, data_type:).build
          end

          private

          def build_metadata_shapes(capabilities, representation_class, type)
            result = ::Apiwork::API::Object.new
            capabilities.each do |capability|
              shape = capability.shape(representation_class, type)
              result.merge_shape!(shape) if shape
            end
            result
          end
        end

        # @api public
        # @return [Symbol, nil] the data type name from serializer
        attr_reader :data_type

        # @api public
        # @return [API::Object] aggregated capability shapes to merge
        attr_reader :metadata_shapes

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
                 :extends,
                 :integer,
                 :integer?,
                 :literal,
                 :merge!,
                 :merge_shape!,
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

        def initialize(target, root_key, metadata_shapes, data_type: nil)
          @target = target
          @root_key = root_key
          @metadata_shapes = metadata_shapes
          @data_type = data_type
        end

        def build
          raise NotImplementedError
        end
      end
    end
  end
end
