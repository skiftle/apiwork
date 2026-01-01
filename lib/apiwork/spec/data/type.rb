# frozen_string_literal: true

module Apiwork
  module Spec
    module Data
      # @api public
      # Wraps custom type definitions.
      #
      # Types can be objects (with shapes) or unions (with variants).
      #
      # @example Object type
      #   type.name         # => :address
      #   type.object?      # => true
      #   type.shape[:city] # => Param for city field
      #
      # @example Union type
      #   type.name          # => :payment_method
      #   type.union?        # => true
      #   type.variants      # => [{ type: :credit_card, ... }, ...]
      #   type.discriminator # => :type
      class Type
        attr_reader :name

        def initialize(name, data)
          @name = name.to_sym
          @data = data || {}
        end

        # @return [Symbol, nil] type kind (:object or :union)
        def type
          @data[:type]
        end

        # @return [Boolean] whether this is an object type
        def object?
          type == :object || type.nil?
        end

        # @return [Boolean] whether this is a union type
        def union?
          type == :union
        end

        # @return [Hash{Symbol => Param}] nested fields for object types
        # @see Param
        def shape
          @shape ||= (@data[:shape] || {}).transform_values { |d| Param.new(d) }
        end

        # @return [Array<Hash>] variants for union types
        def variants
          @data[:variants] || []
        end

        # @return [Symbol, nil] discriminator field for discriminated unions
        def discriminator
          @data[:discriminator]
        end

        # @return [String, nil] type description
        def description
          @data[:description]
        end

        # @return [Object, nil] example value
        def example
          @data[:example]
        end

        # @return [Boolean] whether this type is deprecated
        def deprecated?
          @data[:deprecated] == true
        end

        # @return [Hash] the raw underlying data hash
        def to_h
          @data
        end
      end
    end
  end
end
