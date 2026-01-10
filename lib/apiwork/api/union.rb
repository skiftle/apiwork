# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining reusable union types.
    #
    # Accessed via `union :name do` in API or contract definitions.
    # Use {#variant} to define possible types.
    #
    # @example Discriminated union
    #   union :payment_method, discriminator: :type do
    #     variant tag: 'card' do
    #       object do
    #         string :last_four
    #       end
    #     end
    #     variant tag: 'bank' do
    #       object do
    #         string :account_number
    #       end
    #     end
    #   end
    #
    # @example Simple union
    #   union :amount do
    #     variant { integer }
    #     variant { decimal }
    #   end
    #
    # @see Contract::Union Block context for inline unions
    # @see API::Element Block context for variant types
    class Union
      attr_reader :discriminator,
                  :variants

      def initialize(discriminator: nil)
        @discriminator = discriminator
        @variants = []
      end

      # @api public
      # Defines a variant within this union.
      #
      # The block must define exactly one type using type methods.
      #
      # @param tag [String] discriminator value (required when union has discriminator)
      # @param deprecated [Boolean] mark as deprecated
      # @param description [String] documentation description
      # @param partial [Boolean] mark variant shape as partial
      # @return [void]
      # @see API::Element
      #
      # @example Primitive variant
      #   variant { decimal }
      #
      # @example Object variant
      #   variant tag: 'card' do
      #     object do
      #       string :last_four
      #     end
      #   end
      def variant(deprecated: nil, description: nil, partial: nil, tag: nil, &block)
        validate_tag!(tag)
        raise ArgumentError, 'variant requires a block' unless block

        element = Element.new
        element.instance_eval(&block)
        element.validate!

        data = {
          deprecated:,
          description:,
          partial:,
          tag:,
          custom_type: element.custom_type,
          enum: element.enum,
          of: element.of,
          shape: element.shape,
          type: element.type,
          value: element.value,
        }.compact

        append_or_merge_variant(data, tag)
      end

      private

      def append_or_merge_variant(data, tag)
        if tag && (index = @variants.find_index { |v| v[:tag] == tag })
          existing = @variants[index]
          merge_variant_shapes(existing, data[:shape]) if data[:shape] && existing[:shape]
          data.delete(:shape) if data[:shape] && existing[:shape]
          @variants[index] = existing.merge(data)
        else
          @variants << data
        end
      end

      def merge_variant_shapes(existing_variant, new_shape)
        return unless new_shape.respond_to?(:params)

        new_shape.params.each do |name, param_data|
          existing_variant[:shape].params[name] =
            (existing_variant[:shape].params[name] || {}).merge(param_data)
        end
      end

      def validate_tag!(tag)
        raise ArgumentError, 'tag can only be used when union has a discriminator' if tag.present? && @discriminator.nil?

        return unless @discriminator.present? && tag.blank?

        raise ArgumentError, 'tag is required for all variants when union has a discriminator'
      end
    end
  end
end
