# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Union shape builder with contract context.
    #
    # Wraps {API::Union} and adds contract-specific functionality
    # like enum validation.
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
    # @see Contract::Object#param
    class Union
      attr_reader :contract_class

      delegate :discriminator, :variants, to: :@union

      def initialize(contract_class, discriminator: nil)
        @contract_class = contract_class
        @union = API::Union.new(
          discriminator:,
          object: -> { Object.new(contract_class) },
        )
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
        @union.variant(of:, partial:, tag:, type:, enum: resolve_enum(enum), &block)
      end

      private

      def resolve_enum(enum)
        return nil if enum.nil?
        return enum if enum.is_a?(Array)

        raise ArgumentError, "Enum :#{enum} not found." unless @contract_class.enum?(enum)

        enum
      end
    end
  end
end
