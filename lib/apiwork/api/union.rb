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
    #     variant tag: 'card', type: :object do
    #       param :last_four, type: :string
    #     end
    #     variant tag: 'bank', type: :object do
    #       param :account_number, type: :string
    #     end
    #   end
    #
    # @example Simple union
    #   union :amount do
    #     variant type: :integer
    #     variant type: :decimal
    #   end
    #
    # @see Contract::Union Block context for inline unions
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
      # @param type [Symbol] variant type (primitive, :object, or reference)
      # @param tag [String] discriminator value for this variant (required when union has discriminator)
      # @param enum [Symbol, Array] enum constraint for the variant
      # @param of [Symbol] element type when variant is an array
      # @param partial [Boolean] make all fields optional in this variant
      # @return [void]
      # @see API::Object
      #
      # @example Primitive variant
      #   variant type: :decimal
      #
      # @example Inline object variant
      #   variant tag: 'card', type: :object do
      #     param :last_four, type: :string
      #   end
      def variant(enum: nil, of: nil, partial: nil, shape: nil, tag: nil, type:, &block)
        validate_tag!(tag)

        shape ||= if block && type == :object
                    builder = Object.new
                    builder.instance_eval(&block)
                    builder
                  end

        data = { enum:, of:, partial:, shape:, tag:, type: }.compact

        if tag && (index = @variants.find_index { |variant| variant[:tag] == tag })
          existing = @variants[index]
          merge_variant_shapes(existing, shape) if shape && existing[:shape]
          data.delete(:shape) if shape && existing[:shape]
          @variants[index] = existing.merge(data)
        else
          @variants << data
        end
      end

      private

      def merge_variant_shapes(existing_variant, new_shape)
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
