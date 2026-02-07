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
      #     def apply
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
          def apply(target, root_key, capabilities, representation_class, type, data_type: nil)
            metadata_shapes = build_metadata_shapes(capabilities, representation_class, type)
            new(target, root_key, metadata_shapes, data_type:).apply
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
        # The data type for this shape.
        #
        # @return [Symbol, nil]
        attr_reader :data_type

        # @api public
        # The metadata shapes for this shape.
        #
        # @return [API::Object]
        attr_reader :metadata_shapes

        # @api public
        # The root key for this shape.
        #
        # @return [RootKey]
        attr_reader :root_key

        attr_reader :target

        # @!method array(name, **options, &block)
        #   @api public
        #   @see API::Object#array
        # @!method array?(name, **options, &block)
        #   @api public
        #   @see API::Object#array?
        # @!method binary(name, **options)
        #   @api public
        #   @see API::Object#binary
        # @!method binary?(name, **options)
        #   @api public
        #   @see API::Object#binary?
        # @!method boolean(name, **options)
        #   @api public
        #   @see API::Object#boolean
        # @!method boolean?(name, **options)
        #   @api public
        #   @see API::Object#boolean?
        # @!method date(name, **options)
        #   @api public
        #   @see API::Object#date
        # @!method date?(name, **options)
        #   @api public
        #   @see API::Object#date?
        # @!method datetime(name, **options)
        #   @api public
        #   @see API::Object#datetime
        # @!method datetime?(name, **options)
        #   @api public
        #   @see API::Object#datetime?
        # @!method decimal(name, **options)
        #   @api public
        #   @see API::Object#decimal
        # @!method decimal?(name, **options)
        #   @api public
        #   @see API::Object#decimal?
        # @!method extends(type)
        #   @api public
        #   @see API::Object#extends
        # @!method integer(name, **options)
        #   @api public
        #   @see API::Object#integer
        # @!method integer?(name, **options)
        #   @api public
        #   @see API::Object#integer?
        # @!method literal(name, value:, **options)
        #   @api public
        #   @see API::Object#literal
        # @!method merge!(other)
        #   @api public
        #   @see API::Object#merge!
        # @!method merge_shape!(other)
        #   @api public
        #   @see API::Object#merge_shape!
        # @!method number(name, **options)
        #   @api public
        #   @see API::Object#number
        # @!method number?(name, **options)
        #   @api public
        #   @see API::Object#number?
        # @!method object(name, **options, &block)
        #   @api public
        #   @see API::Object#object
        # @!method object?(name, **options, &block)
        #   @api public
        #   @see API::Object#object?
        # @!method reference(name, **options)
        #   @api public
        #   @see API::Object#reference
        # @!method reference?(name, **options)
        #   @api public
        #   @see API::Object#reference?
        # @!method string(name, **options)
        #   @api public
        #   @see API::Object#string
        # @!method string?(name, **options)
        #   @api public
        #   @see API::Object#string?
        # @!method time(name, **options)
        #   @api public
        #   @see API::Object#time
        # @!method time?(name, **options)
        #   @api public
        #   @see API::Object#time?
        # @!method union(name, **options, &block)
        #   @api public
        #   @see API::Object#union
        # @!method union?(name, **options, &block)
        #   @api public
        #   @see API::Object#union?
        # @!method uuid(name, **options)
        #   @api public
        #   @see API::Object#uuid
        # @!method uuid?(name, **options)
        #   @api public
        #   @see API::Object#uuid?
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

        def apply
          raise NotImplementedError
        end
      end
    end
  end
end
