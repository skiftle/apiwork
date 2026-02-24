# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ErrorCode do
  describe '.find' do
    it 'returns the error code' do
      error_code = described_class.find(:not_found)

      expect(error_code).to be_a(Apiwork::ErrorCode::Definition)
      expect(error_code.key).to eq(:not_found)
    end

    it 'returns nil when not found' do
      expect(described_class.find(:nonexistent)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns the error code' do
      error_code = described_class.find!(:not_found)

      expect(error_code.key).to eq(:not_found)
      expect(error_code.status).to eq(404)
    end

    it 'raises KeyError when not found' do
      expect do
        described_class.find!(:nonexistent)
      end.to raise_error(KeyError, /nonexistent/)
    end
  end

  describe '.register' do
    it 'registers the error code' do
      result = described_class.register(:payment_failed, status: 402)

      expect(result.key).to eq(:payment_failed)
      expect(result.status).to eq(402)
      expect(result.attach_path).to be(false)
    end

    it 'raises ArgumentError when status is invalid' do
      expect do
        described_class.register(:invalid_status, status: 200)
      end.to raise_error(ArgumentError, /400-599/)
    end
  end
end
