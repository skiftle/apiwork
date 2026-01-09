# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Numeric min/max validation' do
  let(:contract_class) { create_test_contract }
  let(:definition) do
    Apiwork::Contract::Object.new(contract_class)
  end

  before do
    definition.param :age, max: 150, min: 18, optional: true, type: :integer
    definition.param :rating, max: 5.0, min: 0.0, optional: true, type: :float
    definition.param :price, max: 99_999.99, min: 0.01, optional: true, type: :decimal
  end

  describe 'integer validation' do
    it 'rejects value below min' do
      result = definition.validate({ age: 17 })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:value_invalid)
      expect(result[:issues].first.meta[:min]).to eq(18)
    end

    it 'accepts value at min boundary' do
      result = definition.validate({ age: 18 })
      expect(result[:issues]).to be_empty
    end

    it 'rejects value above max' do
      result = definition.validate({ age: 151 })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.meta[:max]).to eq(150)
    end
  end

  describe 'float validation' do
    it 'rejects value below min' do
      result = definition.validate({ rating: -0.1 })
      expect(result[:issues]).not_to be_empty
    end

    it 'rejects value above max' do
      result = definition.validate({ rating: 5.1 })
      expect(result[:issues]).not_to be_empty
    end
  end

  describe 'decimal validation' do
    it 'rejects value below min' do
      result = definition.validate({ price: BigDecimal('0.00') })
      expect(result[:issues]).not_to be_empty
    end

    it 'accepts valid price' do
      result = definition.validate({ price: BigDecimal('19.99') })
      expect(result[:issues]).to be_empty
    end
  end

  describe 'optional fields' do
    it 'allows omitting optional fields' do
      result = definition.validate({})
      expect(result[:issues]).to be_empty
    end
  end
end
