# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::TypeRegistry do
  describe '#register' do
    it 'registers the type' do
      registry = described_class.new

      registry.register(:item, kind: :object) { string :title }

      expect(registry[:item]).to be_a(Apiwork::API::TypeRegistry::Definition)
    end

    context 'when key already exists' do
      it 'merges the definition' do
        registry = described_class.new
        registry.register(:item, kind: :object) { string :title }

        registry.register(:item, description: 'An item', kind: :object)

        expect(registry[:item].description).to eq('An item')
      end
    end

    context 'when re-registering with different kind' do
      it 'raises ConfigurationError' do
        registry = described_class.new
        registry.register(:item, kind: :object) { string :title }

        expect do
          registry.register(:item, kind: :union)
        end.to raise_error(Apiwork::ConfigurationError, /Cannot redefine/)
      end
    end
  end

  describe '#scoped_name' do
    it 'returns the scoped name' do
      registry = described_class.new
      scope = Struct.new(:scope_prefix).new('invoice')

      result = registry.scoped_name(scope, :item)

      expect(result).to eq(:invoice_item)
    end

    context 'without scope' do
      it 'returns the name' do
        registry = described_class.new

        result = registry.scoped_name(nil, :item)

        expect(result).to eq(:item)
      end
    end

    context 'without prefix' do
      it 'returns the name' do
        registry = described_class.new
        scope = Struct.new(:scope_prefix).new(nil)

        result = registry.scoped_name(scope, :item)

        expect(result).to eq(:item)
      end
    end

    context 'when name is nil' do
      it 'returns the prefix' do
        registry = described_class.new
        scope = Struct.new(:scope_prefix).new('invoice')

        result = registry.scoped_name(scope, nil)

        expect(result).to eq(:invoice)
      end
    end
  end
end
