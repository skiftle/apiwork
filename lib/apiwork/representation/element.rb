# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Block context for defining JSON blob structure in representation attributes.
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
    class Element < Apiwork::Element
      # Representation::Element uses different of_type semantics - returns the array inner type.
      def of_type
        @of
      end

      def validate!
        raise ArgumentError, 'must define exactly one type (object, array, or union)' unless @defined
      end

      # @api public
      # Defines the element type.
      #
      # Only complex types (:object, :array, :union) are allowed.
      #
      # @param type [Symbol] element type (:object, :array, :union)
      # @param discriminator [Symbol, nil] discriminator field name (unions only)
      # @param shape [API::Object, API::Union, nil] pre-built shape
      # @yield block for defining nested structure (instance_eval style)
      # @yieldparam builder [API::Object, API::Union, API::Element] the builder (yield style)
      # @return [void]
      def of(type, discriminator: nil, shape: nil, **_options, &block)
        case type
        when :object
          if shape
            @type = :object
            @shape = shape
            @defined = true
          elsif block
            builder = API::Object.new
            block.arity.positive? ? yield(builder) : builder.instance_eval(&block)
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
            block.arity.positive? ? yield(inner) : inner.instance_eval(&block)
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
            block.arity.positive? ? yield(builder) : builder.instance_eval(&block)
            @type = :union
            @shape = builder
            @discriminator = discriminator
            @defined = true
          else
            raise ArgumentError, 'union requires a block or shape'
          end
        else
          raise ArgumentError, "Representation::Element only supports :object, :array, :union - got #{type.inspect}"
        end
      end
    end
  end
end
