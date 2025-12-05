# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Numeric min/max validation' do
  let(:contract_class) { create_test_contract }
  let(:definition) do
    Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class)
  end

  before do
    definition.param :age, type: :integer, optional: true, min: 18, max: 150
    definition.param :rating, type: :float, optional: true, min: 0.0, max: 5.0
    definition.param :price, type: :decimal, optional: true, min: 0.01, max: 99_999.99
  end

  describe 'integer validation' do
    it 'rejects value below min' do
      result = definition.validate({ age: 17 })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:invalid_value)
      expect(result[:issues].first.detail).to match(/must be >= 18/)
    end

    it 'accepts value at min boundary' do
      result = definition.validate({ age: 18 })
      expect(result[:issues]).to be_empty
    end

    it 'rejects value above max' do
      result = definition.validate({ age: 151 })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.detail).to match(/must be <= 150/)
    end
  end

  describe 'float validation' do
    it 'validates min constraint' do
      result = definition.validate({ rating: -0.1 })
      expect(result[:issues]).not_to be_empty
    end

    it 'validates max constraint' do
      result = definition.validate({ rating: 5.1 })
      expect(result[:issues]).not_to be_empty
    end
  end

  describe 'decimal validation' do
    it 'validates min constraint' do
      result = definition.validate({ price: BigDecimal('0.00') })
      expect(result[:issues]).not_to be_empty
    end

    it 'accepts valid price' do
      result = definition.validate({ price: BigDecimal('19.99') })
      expect(result[:issues]).to be_empty
    end
  end
end
