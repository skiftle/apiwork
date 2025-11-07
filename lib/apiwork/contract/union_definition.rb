# frozen_string_literal: true

module Apiwork
  module Contract
    # UnionDefinition handles union type definitions within contracts
    # A union represents a parameter that can be one of several type alternatives
    class UnionDefinition
      attr_reader :variants, :contract_class, :type_scope

      def initialize(contract_class, type_scope: :root)
        @contract_class = contract_class
        @type_scope = type_scope
        @variants = []
      end

      # Define a variant (type alternative) in the union
      # @param type [Symbol] The type of this variant
      # @param of [Symbol, nil] For arrays, the type of array items
      # @param enum [Array, nil] For string/integer types, allowed values
      # @param block [Proc, nil] Block for shape params (for :object or :array of :object)
      def variant(type:, of: nil, enum: nil, &block)
        variant_def = {
          type: type,
          of: of
        }

        variant_def[:enum] = enum if enum

        # Handle shape block (for :object or :array with :object items)
        if block_given?
          shape_def = Definition.new(:input, @contract_class, type_scope: @type_scope)
          shape_def.instance_eval(&block)
          variant_def[:shape] = shape_def
        end

        @variants << variant_def
      end
    end
  end
end
