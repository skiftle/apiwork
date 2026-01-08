# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Defines variants in a union type.
    #
    # Used inside union blocks in contracts and custom adapters.
    # The {#variant} method defines each possible type the union can hold.
    #
    # @example In a contract
    #   param :payment, type: :union, discriminator: :type do
    #     variant type: :object, tag: 'card' do
    #       param :card_number, type: :string
    #     end
    #     variant type: :object, tag: 'bank' do
    #       param :account_number, type: :string
    #     end
    #   end
    #
    # @see Contract::Param#param
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
      # Defines a variant in a union type.
      #
      # @param type [Symbol] the variant type (:string, :integer, :object, etc.)
      # @param of [Symbol] element type for :array variants
      # @param enum [Array, Symbol] allowed values for this variant
      # @param tag [String] discriminator value (required when union has discriminator)
      # @param partial [Boolean] allow partial object (omit required fields)
      # @yield nested params for :object variants
      #
      # @example Simple variants
      #   variant type: :string
      #   variant type: :integer
      #
      # @example Discriminated union
      #   variant type: :object, tag: 'card' do
      #     param :card_number, type: :string
      #   end
      #
      # @see Contract::Param#param
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
    end
  end
end
