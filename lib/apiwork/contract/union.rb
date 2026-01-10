# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Block context for defining inline union types.
    #
    # Accessed via `param :x, type: :union do` inside contract actions.
    # Use {#variant} to define possible types.
    #
    # @example Discriminated union
    #   param :payment, type: :union, discriminator: :type do
    #     variant tag: 'card', type: :object do
    #       param :card_number, type: :string
    #     end
    #     variant tag: 'bank', type: :object do
    #       param :account_number, type: :string
    #     end
    #   end
    #
    # @see API::Union Block context for reusable unions
    class Union
      attr_reader :contract_class,
                  :discriminator,
                  :variants

      def initialize(contract_class, discriminator: nil)
        @contract_class = contract_class
        @discriminator = discriminator
        @variants = []
      end

      # @api public
      # Defines a variant in this union.
      #
      # @param type [Symbol] the variant type (:string, :integer, :object, etc.)
      # @param of [Symbol] element type for :array variants
      # @param enum [Array, Symbol] allowed values for this variant
      # @param tag [String] discriminator value (required when union has discriminator)
      # @param partial [Boolean] allow partial object (omit required fields)
      # @yield nested params for :object variants
      # @return [void]
      #
      # @example Simple union (string or integer)
      #   param :value, type: :union do
      #     variant type: :string
      #     variant type: :integer
      #   end
      #
      # @example Discriminated union with object variants
      #   param :payment, type: :union, discriminator: :type do
      #     variant type: :object, tag: 'card' do
      #       param :card_number, type: :string
      #       param :expiry, type: :string
      #     end
      #     variant type: :object, tag: 'bank' do
      #       param :account_number, type: :string
      #       param :routing_number, type: :string
      #     end
      #   end
      def variant(enum: nil, of: nil, partial: nil, tag: nil, type:, &block)
        validate_tag!(tag)

        shape = if block && type == :object
                  builder = Object.new(@contract_class)
                  builder.instance_eval(&block)
                  builder
                end

        resolved_enum = resolve_enum(enum)
        data = { of:, partial:, shape:, tag:, type:, enum: resolved_enum }.compact

        if tag && (index = @variants.find_index { |v| v[:tag] == tag })
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

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "Enum :#{enum} not found." unless @contract_class.enum?(enum)

        enum
      end
    end
  end
end
