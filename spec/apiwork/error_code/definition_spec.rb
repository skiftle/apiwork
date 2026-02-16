# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ErrorCode::Definition do
  describe '#initialize' do
    it 'creates with required attributes' do
      definition = described_class.new(attach_path: true, key: :not_found, status: 404)

      expect(definition.key).to eq(:not_found)
      expect(definition.status).to eq(404)
      expect(definition.attach_path).to be(true)
    end
  end

  describe '#attach_path?' do
    it 'returns true when attach_path' do
      definition = described_class.new(attach_path: true, key: :not_found, status: 404)

      expect(definition.attach_path?).to be(true)
    end

    it 'returns false when not attach_path' do
      definition = described_class.new(attach_path: false, key: :bad_request, status: 400)

      expect(definition.attach_path?).to be(false)
    end
  end

  describe '#description' do
    it 'returns the titleized key' do
      definition = described_class.new(attach_path: false, key: :payment_failed, status: 402)

      expect(definition.description).to eq('Payment Failed')
    end
  end
end
