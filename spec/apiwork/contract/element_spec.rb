# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Element do
  let(:contract_class) { create_test_contract }

  describe '#inner' do
    it 'returns nil for primitives' do
      element = described_class.new(contract_class)
      element.string

      expect(element.inner).to be_nil
    end

    it 'returns inner element for array' do
      element = described_class.new(contract_class)
      element.array do
        string
      end

      expect(element.inner).to be_a(described_class)
      expect(element.inner.type).to eq(:string)
    end

    it 'preserves constraints on inner element' do
      element = described_class.new(contract_class)
      element.array do
        integer max: 100, min: 0
      end

      expect(element.inner.min).to eq(0)
      expect(element.inner.max).to eq(100)
    end
  end

  describe 'nested arrays' do
    it 'creates array of arrays' do
      element = described_class.new(contract_class)
      element.array do
        array do
          string
        end
      end

      expect(element.type).to eq(:array)
      expect(element.item_type).to eq(:array)
      expect(element.inner.type).to eq(:array)
      expect(element.inner.item_type).to eq(:string)
    end

    it 'preserves constraints through nested arrays' do
      element = described_class.new(contract_class)
      element.array do
        array do
          decimal max: 1.0, min: 0.0
        end
      end

      inner_inner = element.inner.inner

      expect(inner_inner.type).to eq(:decimal)
      expect(inner_inner.min).to eq(0.0)
      expect(inner_inner.max).to eq(1.0)
    end

    it 'creates deeply nested arrays' do
      element = described_class.new(contract_class)
      element.array do
        array do
          array do
            string format: :uuid
          end
        end
      end

      level1 = element.inner
      level2 = level1.inner
      level3 = level2.inner

      expect(level1.type).to eq(:array)
      expect(level2.type).to eq(:array)
      expect(level3.type).to eq(:string)
      expect(level3.format).to eq(:uuid)
    end

    it 'creates array of arrays of objects' do
      element = described_class.new(contract_class)
      element.array do
        array do
          object do
            string :name
            integer :quantity
          end
        end
      end

      expect(element.type).to eq(:array)
      expect(element.item_type).to eq(:array)
      expect(element.inner.item_type).to eq(:object)
      expect(element.inner.inner.shape).to be_a(Apiwork::Contract::Object)
      expect(element.inner.inner.shape.params.keys).to eq(%i[name quantity])
    end
  end
end
