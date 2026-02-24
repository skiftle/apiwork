# frozen_string_literal: true

module Apiwork
  module Adapter
    module Wrapper
      # @api public
      # Base class for wrapper shapes.
      #
      # Subclass to define response type structure for record or collection wrappers.
      # The block is evaluated via instance_exec, providing access to type DSL methods
      # and helpers like root_key and {#metadata_type_names}.
      #
      # @example Custom shape class
      #   class MyShape < Wrapper::Shape
      #     def apply
      #       reference(:invoice)
      #       object?(:meta)
      #       metadata_type_names.each { |type_name| merge(type_name) }
      #     end
      #   end
      #
      # @example Inline shape block
      #   shape do
      #     reference(root_key.singular.to_sym)
      #     object?(:meta)
      #     metadata_type_names.each { |type_name| merge(type_name) }
      #   end
      class Shape
        class << self
          def apply(target, root_key, capabilities, representation_class, type, data_type: nil)
            metadata_type_names = build_metadata_type_names(capabilities, representation_class, type)
            new(target, root_key, metadata_type_names, data_type:).apply
          end

          private

          def build_metadata_type_names(capabilities, representation_class, type)
            capabilities.filter_map { |capability| capability.shape(representation_class, type) }
          end
        end

        # @!attribute [r] data_type
        #   @api public
        #   The data type for this shape.
        #
        #   @return [Symbol, nil]
        # @!attribute [r] metadata_type_names
        #   @api public
        #   The metadata type names for this shape.
        #
        #   Auto-generated type names from capability {Adapter::Capability::Operation::Base.metadata_shape}
        #   definitions. Use with {#merge} to include capability metadata fields in the shape.
        #
        #   @return [Array<Symbol>]
        # @!attribute [r] root_key
        #   @api public
        #   The root key for this shape.
        #
        #   @return [RootKey]
        attr_reader :data_type,
                    :metadata_type_names,
                    :root_key

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
        # @!method merge(other)
        #   @api public
        #   @see API::Object#merge
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
                 :merge,
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
                 to: :@target

        def initialize(target, root_key, metadata_type_names, data_type: nil)
          @target = target
          @root_key = root_key
          @metadata_type_names = metadata_type_names
          @data_type = data_type
        end

        def apply
          raise NotImplementedError
        end
      end
    end
  end
end
