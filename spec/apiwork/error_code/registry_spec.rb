# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ErrorCode::Registry do
  before { described_class.clear! }

  describe '.register' do
    it 'stores definition with correct attributes' do
      described_class.register(:test_error, status: 400)

      definition = described_class.find!(:test_error)
      expect(definition.key).to eq(:test_error)
      expect(definition.status).to eq(400)
    end

    it 'converts string key to symbol' do
      described_class.register('string_key', status: 404)

      expect(described_class.registered?(:string_key)).to be(true)
    end

    it 'converts status to integer' do
      described_class.register(:test_error, status: '422')

      definition = described_class.find!(:test_error)
      expect(definition.status).to eq(422)
    end

    it 'raises ArgumentError for status below 400' do
      expect do
        described_class.register(:test_error, status: 200)
      end.to raise_error(ArgumentError, 'Status must be 400-599, got 200')
    end

    it 'raises ArgumentError for status above 599' do
      expect do
        described_class.register(:test_error, status: 600)
      end.to raise_error(ArgumentError, 'Status must be 400-599, got 600')
    end

    it 'accepts status 400' do
      expect { described_class.register(:test_error, status: 400) }.not_to raise_error
    end

    it 'accepts status 599' do
      expect { described_class.register(:test_error, status: 599) }.not_to raise_error
    end
  end

  describe '.find!' do
    before { described_class.register(:existing, status: 404) }

    it 'returns definition for registered code' do
      definition = described_class.find!(:existing)

      expect(definition).to be_a(Apiwork::ErrorCode::Definition)
      expect(definition.key).to eq(:existing)
    end

    it 'converts string key to symbol' do
      definition = described_class.find!('existing')

      expect(definition.key).to eq(:existing)
    end

    it 'raises KeyError for unknown code' do
      expect do
        described_class.find!(:unknown)
      end.to raise_error(KeyError, /Registry :unknown not found/)
    end

    it 'includes available codes in error message' do
      described_class.register(:another, status: 500)

      expect do
        described_class.find!(:unknown)
      end.to raise_error(KeyError, /Available: existing, another/)
    end
  end

  describe '.registered?' do
    before { described_class.register(:existing, status: 404) }

    it 'returns true for registered code' do
      expect(described_class.registered?(:existing)).to be(true)
    end

    it 'returns false for unregistered code' do
      expect(described_class.registered?(:unknown)).to be(false)
    end

    it 'converts string key to symbol' do
      expect(described_class.registered?('existing')).to be(true)
    end
  end

  describe '.all' do
    it 'returns empty array when no codes registered' do
      expect(described_class.all).to eq([])
    end

    it 'returns all registered keys' do
      described_class.register(:first, status: 400)
      described_class.register(:second, status: 500)

      expect(described_class.all).to contain_exactly(:first, :second)
    end
  end

  describe '.clear!' do
    it 'removes all registered codes' do
      described_class.register(:test, status: 404)
      expect(described_class.all).not_to be_empty

      described_class.clear!

      expect(described_class.all).to be_empty
    end
  end
end
