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

      def variant(type:, of: nil, enum: nil, tag: nil, partial: nil, &block)
        raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.blank?

        raise ArgumentError, 'tag is required for all variants when union has a discriminator' if @discriminator.present? && tag.blank?

        variant_definition = {
          type: type,
          of: of
        }

        variant_definition[:enum] = enum if enum
        variant_definition[:tag] = tag if tag
        variant_definition[:partial] = partial ? true : false

        if block_given?
          shape_definition = Definition.new(type: :body, contract_class: @contract_class)
          shape_definition.instance_eval(&block)
          variant_definition[:shape] = shape_definition
        end

        @variants << variant_definition
      end

      def serialize
        serialized_variants = @variants.map do |variant|
          serialized = variant.dup
          serialized[:shape] = serialized[:shape].as_json if serialized[:shape].is_a?(Apiwork::Contract::Definition)
          serialized
        end

        {
          type: :union,
          required: false,
          nullable: false,
          variants: serialized_variants,
          discriminator: @discriminator
        }.compact # Remove nil discriminator if not set
      end
    end
  end
end
