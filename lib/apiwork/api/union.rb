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
    class Union < Apiwork::Union
      private

      def build_element
        Element.new
      end
    end
  end
end
