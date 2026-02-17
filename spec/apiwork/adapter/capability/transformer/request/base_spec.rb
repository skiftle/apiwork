# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Transformer::Request::Base do
  describe '#initialize' do
    it 'creates with required attributes' do
      request = Apiwork::Request.new(body: {}, query: {})
      transformer = described_class.new(request)

      expect(transformer.request).to eq(request)
    end
  end

  describe '.phase' do
    it 'returns the phase' do
      transformer_class = Class.new(described_class) do
        phase :after
      end

      expect(transformer_class.phase).to eq(:after)
    end

    it 'returns :before when not set' do
      transformer_class = Class.new(described_class)

      expect(transformer_class.phase).to eq(:before)
    end
  end

  describe '#transform' do
    it 'raises NotImplementedError' do
      request = Apiwork::Request.new(body: {}, query: {})
      transformer = described_class.new(request)

      expect { transformer.transform }.to raise_error(NotImplementedError)
    end
  end
end
