# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter do
  describe '.find' do
    it 'returns the adapter' do
      adapter_class = described_class.find(:standard)

      expect(adapter_class).to eq(Apiwork::Adapter::Standard)
    end

    it 'returns nil when not found' do
      expect(described_class.find(:nonexistent)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns the adapter' do
      adapter_class = described_class.find!(:standard)

      expect(adapter_class).to eq(Apiwork::Adapter::Standard)
    end

    it 'raises KeyError when not found' do
      expect do
        described_class.find!(:nonexistent)
      end.to raise_error(KeyError, /nonexistent/)
    end
  end

  describe '.register' do
    it 'registers the adapter' do
      adapter_class = Class.new(Apiwork::Adapter::Base) do
        adapter_name :unit_adapter_register
      end
      described_class.register(adapter_class)

      expect(described_class.find(:unit_adapter_register)).to eq(adapter_class)
    end
  end
end
