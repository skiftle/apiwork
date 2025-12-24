# frozen_string_literal: true

module Apiwork
  module Contract
    class UnionDefinition
      attr_reader :contract_class,
                  :discriminator,
                  :variants

      def initialize(contract_class, discriminator: nil)
        @contract_class = contract_class
        @discriminator = discriminator
        @variants = []
      end

      # Defines a variant in a union type.
      #
      # Each variant represents one possible shape the union can take.
      # For discriminated unions, each variant must have a unique tag.
      #
      # @param type [Symbol] variant type (:string, :integer, :object, :array, or custom type)
      # @param of [Symbol] element type for :array variants
      # @param enum [Array] allowed values for primitive variants
      # @param tag [String, Symbol] discriminator value (required for discriminated unions)
      # @param partial [Boolean] mark as partial variant
      # @yield block defining nested params for object variants
      #
      # @example Discriminated union
      #   union :result, discriminator: :status do
      #     variant type: :object, tag: 'success' do
      #       param :data, type: :object
      #     end
      #     variant type: :object, tag: 'error' do
      #       param :message, type: :string
      #     end
      #   end
      #
      # @example Simple type union
      #   union :id do
      #     variant type: :string
      #     variant type: :integer
      #   end
      def variant(type:, of: nil, enum: nil, tag: nil, partial: nil, &block)
        raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.blank?

        raise ArgumentError, 'tag is required for all variants when union has a discriminator' if @discriminator.present? && tag.blank?

        variant_definition = {
          type: type,
          of: of,
          enum: enum,
          tag: tag
        }.compact
        variant_definition[:partial] = true if partial

        if block_given?
          shape_definition = ParamDefinition.new(type: :body, contract_class: @contract_class)
          shape_definition.instance_eval(&block)
          variant_definition[:shape] = shape_definition
        end

        @variants << variant_definition
      end

      def serialize
        serialized_variants = @variants.map do |variant|
          serialized = variant.dup
          serialized[:shape] = serialized[:shape].as_json if serialized[:shape].is_a?(Apiwork::Contract::ParamDefinition)
          serialized
        end

        {
          type: :union,
          variants: serialized_variants,
          discriminator: @discriminator
        }.compact
      end
    end
  end
end
