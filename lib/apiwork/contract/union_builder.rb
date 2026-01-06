# frozen_string_literal: true

module Apiwork
  module Contract
    class UnionBuilder
      attr_reader :contract_class,
                  :discriminator,
                  :variants

      def initialize(contract_class, discriminator: nil)
        @contract_class = contract_class
        @discriminator = discriminator
        @variants = []
      end

      def variant(
        type:,
        of: nil,
        enum: nil,
        tag: nil,
        partial: nil,
        &block
      )
        raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.blank?

        raise ArgumentError, 'tag is required for all variants when union has a discriminator' if @discriminator.present? && tag.blank?

        variant_definition = {
          enum:,
          of:,
          tag:,
          type:,
        }.compact
        variant_definition[:partial] = true if partial

        if block_given?
          shape_param = Param.new(@contract_class)
          shape_param.instance_eval(&block)
          variant_definition[:shape] = shape_param
        end

        @variants << variant_definition
      end

      def serialize
        serialized_variants = @variants.map do |variant|
          serialized = variant.dup
          serialized[:shape] = serialized[:shape].as_json if serialized[:shape].is_a?(Param)
          serialized
        end

        {
          discriminator: @discriminator,
          type: :union,
          variants: serialized_variants,
        }.compact
      end
    end
  end
end
