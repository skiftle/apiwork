# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::EnumRegistry do
  describe '#register' do
    it 'registers the enum' do
      registry = described_class.new

      registry.register(:status, %w[draft sent paid])

      expect(registry[:status]).to be_a(Apiwork::API::EnumRegistry::Definition)
    end

    context 'when key already exists' do
      it 'merges the definition' do
        registry = described_class.new
        registry.register(:status, %w[draft])

        registry.register(:status, %w[draft sent paid])

        expect(registry[:status].values).to eq(%w[draft sent paid])
      end
    end
  end

  describe '#scoped_name' do
    it 'returns the scoped name' do
      registry = described_class.new
      scope = Struct.new(:scope_prefix).new('invoice')

      result = registry.scoped_name(scope, :status)

      expect(result).to eq(:invoice_status)
    end

    context 'without scope' do
      it 'returns the name' do
        registry = described_class.new

        result = registry.scoped_name(nil, :status)

        expect(result).to eq(:status)
      end
    end

    context 'without prefix' do
      it 'returns the name' do
        registry = described_class.new
        scope = Struct.new(:scope_prefix).new(nil)

        result = registry.scoped_name(scope, :status)

        expect(result).to eq(:status)
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
