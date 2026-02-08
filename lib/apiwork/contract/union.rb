# frozen_string_literal: true

module Apiwork
  module Contract
    # @api public
    # Block context for defining inline union types.
    #
    # Accessed via `union :name, discriminator: do` inside contract actions.
    # Use {#variant} to define possible types.
    #
    # @example instance_eval style
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
    # @example yield style
    #   union :payment_method, discriminator: :type do |union|
    #     union.variant tag: 'card' do |variant|
    #       variant.object do |object|
    #         object.string :last_four
    #       end
    #     end
    #     union.variant tag: 'bank' do |variant|
    #       variant.object do |object|
    #         object.string :account_number
    #       end
    #     end
    #   end
    #
    # @see API::Union Block context for reusable unions
    # @see Contract::Element Block context for variant types
    class Union < Apiwork::Union
      attr_reader :contract_class

      def initialize(contract_class, discriminator: nil)
        super(discriminator:)
        @contract_class = contract_class
      end

      private

      def build_element
        Element.new(@contract_class)
      end
    end
  end
end
