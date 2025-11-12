# frozen_string_literal: true

module Apiwork
  module Contract
    # UnionDefinition handles union type definitions within contracts
    # A union represents a parameter that can be one of several type alternatives
    class UnionDefinition
      attr_reader :variants, :contract_class, :discriminator

      def initialize(contract_class, discriminator: nil)
        @contract_class = contract_class
        @discriminator = discriminator
        @variants = []
      end

      # Define a variant (type alternative) in the union
      # @param type [Symbol] The type of this variant
      # @param of [Symbol, nil] For arrays, the type of array items
      # @param enum [Array, nil] For string/integer types, allowed values
      # @param tag [String, nil] Tag value for discriminated unions
      # @param block [Proc, nil] Block for shape params (for :object or :array of :object)
      def variant(type:, of: nil, enum: nil, tag: nil, &block)
        # Validate tag usage with discriminator
        raise ArgumentError, 'tag can only be used when union has a discriminator' if tag && !@discriminator

        raise ArgumentError, 'tag is required for all variants when union has a discriminator' if @discriminator && !tag

        variant_def = {
          type: type,
          of: of
        }

        variant_def[:enum] = enum if enum
        variant_def[:tag] = tag if tag

        # Handle shape block (for :object or :array with :object items)
        if block_given?
          shape_def = Definition.new(:input, @contract_class)
          shape_def.instance_eval(&block)
          variant_def[:shape] = shape_def
        end

        @variants << variant_def
      end
    end
  end
end
