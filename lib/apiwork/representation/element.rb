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
    # @see API::Element Block context for array elements
    # @see API::Object Block context for object fields
    # @see API::Union Block context for union variants
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
      # @param type [Symbol] [:array, :object, :union]
      #   The element type.
      # @param discriminator [Symbol, nil] (nil)
      #   The discriminator field name. Unions only.
      # @yield block for defining nested structure (instance_eval style)
      # @yieldparam shape [API::Object, API::Union, API::Element]
      # @return [void]
      # @raise [ArgumentError] if object, array, or union type is missing block
      def of(type, discriminator: nil, &block)
        case type
        when :object
          raise ArgumentError, 'object requires a block' unless block

          builder = API::Object.new
          block.arity.positive? ? yield(builder) : builder.instance_eval(&block)
          @type = :object
          @shape = builder
          @defined = true
        when :array
          raise ArgumentError, 'array requires a block' unless block

          inner = API::Element.new
          block.arity.positive? ? yield(inner) : inner.instance_eval(&block)
          inner.validate!
          @type = :array
          @of = inner.of_type
          @shape = inner.shape
          @defined = true
        when :union
          raise ArgumentError, 'union requires a block' unless block

          builder = API::Union.new(discriminator:)
          block.arity.positive? ? yield(builder) : builder.instance_eval(&block)
          @type = :union
          @shape = builder
          @discriminator = discriminator
          @defined = true
        else
          raise ArgumentError, "Representation::Element only supports :object, :array, :union - got #{type.inspect}"
        end
      end
    end
  end
end
