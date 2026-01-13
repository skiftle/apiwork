# frozen_string_literal: true

module Apiwork
  module Schema
    # @api public
    # Block context for defining JSON blob structure in schema attributes.
    #
    # Used inside attribute blocks to define the shape of JSON/JSONB columns,
    # Rails store attributes, or any serialized data structure.
    #
    # Only complex types are allowed at the top level:
    # - {#object} for key-value structures
    # - {#array} for ordered collections
    # - {#union} for polymorphic structures
    #
    # Inside these blocks, the full type DSL is available including
    # nested objects, arrays, primitives, and unions.
    #
    # @example Object structure
    #   attribute :settings do
    #     object do
    #       string :theme
    #       boolean :notifications
    #       integer :max_items, min: 1, max: 100
    #     end
    #   end
    #
    # @example Array of objects
    #   attribute :addresses do
    #     array do
    #       object do
    #         string :street
    #         string :city
    #         string :zip
    #         boolean :primary
    #       end
    #     end
    #   end
    #
    # @example Nested structures
    #   attribute :config do
    #     object do
    #       string :name
    #       array :tags do
    #         string
    #       end
    #       object :metadata do
    #         datetime :created_at
    #         datetime :updated_at
    #       end
    #     end
    #   end
    #
    # @example Union for polymorphic data
    #   attribute :payment_details do
    #     union discriminator: :type do
    #       variant tag: 'card' do
    #         object do
    #           string :last_four
    #           string :brand
    #         end
    #       end
    #       variant tag: 'bank' do
    #         object do
    #           string :account_number
    #           string :routing_number
    #         end
    #       end
    #     end
    #   end
    #
    # @see API::Object Block context for object fields
    # @see API::Element Block context for array elements
    # @see API::Union Block context for union variants
    class Element
      # @api public
      # @return [Symbol, nil] the discriminator field for unions
      attr_reader :discriminator

      # @api public
      # @return [API::Object, API::Union, nil] the shape builder
      attr_reader :shape

      # @api public
      # @return [Symbol] the element type (:object, :array, :union)
      attr_reader :type

      def initialize
        @defined = false
        @discriminator = nil
        @of = nil
        @shape = nil
        @type = nil
      end

      # @api public
      # Defines the element type.
      #
      # This is the verbose form. Prefer sugar methods (object, array, union)
      # for static definitions.
      #
      # @param type [Symbol] element type (:object, :array, :union)
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param shape [API::Object, API::Union, nil] pre-built shape
      # @yield block for defining nested structure
      # @return [void]
      def of(type, discriminator: nil, shape: nil, &block)
        case type
        when :object
          if shape
            @type = :object
            @shape = shape
            @defined = true
          elsif block
            builder = API::Object.new
            builder.instance_eval(&block)
            @type = :object
            @shape = builder
            @defined = true
          else
            raise ArgumentError, 'object requires a block or shape'
          end
        when :array
          if shape
            @type = :array
            @shape = shape
            @defined = true
          elsif block
            inner = API::Element.new
            inner.instance_eval(&block)
            inner.validate!
            @type = :array
            @of = inner.of_type
            @shape = inner.shape
            @defined = true
          else
            raise ArgumentError, 'array requires a block or shape'
          end
        when :union
          if shape
            @type = :union
            @shape = shape
            @discriminator = discriminator
            @defined = true
          elsif block
            builder = API::Union.new(discriminator:)
            builder.instance_eval(&block)
            @type = :union
            @shape = builder
            @discriminator = discriminator
            @defined = true
          else
            raise ArgumentError, 'union requires a block or shape'
          end
        else
          raise ArgumentError, "Schema::Element only supports :object, :array, :union - got #{type.inspect}"
        end
      end

      # @api public
      # Defines an object structure.
      #
      # The block is evaluated in {API::Object} context, providing
      # access to all field definition methods.
      #
      # @yield block defining object fields
      # @return [void]
      # @raise [ArgumentError] if no block given
      # @see API::Object
      #
      # @example
      #   object do
      #     string :name
      #     integer :count
      #     boolean :active
      #   end
      def object(&block)
        of(:object, &block)
      end

      # @api public
      # Defines an array structure.
      #
      # The block is evaluated in {API::Element} context, where
      # exactly one element type must be defined.
      #
      # @yield block defining element type
      # @return [void]
      # @raise [ArgumentError] if no block given
      # @see API::Element
      #
      # @example Array of strings
      #   array do
      #     string
      #   end
      #
      # @example Array of objects
      #   array do
      #     object do
      #       string :id
      #       string :name
      #     end
      #   end
      def array(&block)
        of(:array, &block)
      end

      # @api public
      # Defines a union structure for polymorphic data.
      #
      # The block is evaluated in {API::Union} context, where
      # variants are defined using the `variant` method.
      #
      # @param discriminator [Symbol] field name that identifies the variant
      # @yield block defining union variants
      # @return [void]
      # @raise [ArgumentError] if no block given
      # @see API::Union
      #
      # @example
      #   union discriminator: :type do
      #     variant tag: 'email' do
      #       object do
      #         string :address
      #       end
      #     end
      #     variant tag: 'sms' do
      #       object do
      #         string :phone_number
      #       end
      #     end
      #   end
      def union(discriminator: nil, &block)
        of(:union, discriminator:, &block)
      end

      def of_type
        @of
      end

      def of_value
        @of
      end

      def validate!
        raise ArgumentError, 'must define exactly one type (object, array, or union)' unless @defined
      end
    end
  end
end
