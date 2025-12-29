# frozen_string_literal: true

module Apiwork
  module API
    class TypeSystem
      class UnionBuilder
        attr_reader :discriminator,
                    :variants

        def initialize(discriminator: nil)
          @discriminator = discriminator
          @variants = []
        end

        def variant(type:,
                    of: nil,
                    enum: nil,
                    tag: nil,
                    partial: nil,
                    &block)
          validate_tag!(tag)

          variant_data = { type: }
          variant_data[:of] = of if of
          variant_data[:enum] = enum if enum
          variant_data[:tag] = tag if tag
          variant_data[:partial] = true if partial
          variant_data[:shape_block] = block if block_given?

          @variants << variant_data
        end

        def serialize
          {
            type: :union,
            variants: @variants.dup,
            discriminator: @discriminator
          }.compact
        end

        private

        def validate_tag!(tag)
          raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.blank?

          raise ArgumentError, 'tag is required for all variants when union has a discriminator' if @discriminator.present? && tag.blank?
        end
      end
    end
  end
end
