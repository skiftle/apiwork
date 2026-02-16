# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Element do
  describe '#of' do
    context 'when type is a primitive' do
      it 'sets the type' do
        contract_class = create_test_contract
        element = described_class.new(contract_class)
        element.of(:string)

        expect(element.type).to eq(:string)
      end
    end

    context 'when type is :object' do
      it 'sets the type and shape' do
        contract_class = create_test_contract
        element = described_class.new(contract_class)
        element.of(:object) do
          string :title
        end

        expect(element.type).to eq(:object)
        expect(element.shape).to be_a(Apiwork::Contract::Object)
      end
    end

    context 'when type is a custom reference' do
      it 'sets the custom type' do
        contract_class = create_test_contract do
          object :item do
            string :title
          end
        end
        element = described_class.new(contract_class)
        element.of(:item)

        expect(element.type).to eq(:item)
        expect(element.custom_type).to eq(:item)
      end
    end
  end

  describe '#string' do
    it 'sets the type to string' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.string

      expect(element.type).to eq(:string)
    end
  end
end
