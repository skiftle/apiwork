# frozen_string_literal: true

module Apiwork
  module API
    # @api public
    # Block context for defining reusable union types.
    #
    # Accessed via `union :name do` in API or contract definitions.
    # Use {#variant} to define possible types.
    #
    # @see API::Element Block context for variant types
    # @see Contract::Union Block context for inline unions
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
    class Union < Apiwork::Union
      private

      def build_element
        Element.new
      end
    end
  end
end
