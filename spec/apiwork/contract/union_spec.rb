# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Union do
  describe '#variant' do
    context 'with defaults' do
      it 'defines a variant' do
        contract_class = create_test_contract
        union = described_class.new(contract_class, discriminator: :type)
        union.variant(tag: 'card') do
          object do
            string :last_four
          end
        end

        variant = union.variants.first
        expect(variant[:tag]).to eq('card')
        expect(variant[:type]).to eq(:object)
        expect(variant[:deprecated]).to be(false)
        expect(variant[:partial]).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        contract_class = create_test_contract
        union = described_class.new(contract_class, discriminator: :type)
        union.variant(
          deprecated: true,
          description: 'Card payment',
          partial: true,
          tag: 'card',
        ) do
          object do
            string :last_four
          end
        end

        variant = union.variants.first
        expect(variant[:deprecated]).to be(true)
        expect(variant[:description]).to eq('Card payment')
        expect(variant[:partial]).to be(true)
        expect(variant[:tag]).to eq('card')
      end
    end
  end
end
