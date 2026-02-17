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
    context 'when locale_key is provided' do
      it 'returns the API-specific translation' do
        definition = described_class.new(attach_path: false, key: :unit_test_api_specific, status: 404)
        I18n.backend.store_translations(:en, apiwork: { apis: { 'api/v1': { error_codes: { unit_test_api_specific: { description: 'Resource not found' } } } } })

        expect(definition.description(locale_key: 'api/v1')).to eq('Resource not found')
      end

      it 'returns the global translation when API-specific is missing' do
        definition = described_class.new(attach_path: false, key: :unit_test_global_fallback, status: 400)
        I18n.backend.store_translations(:en, apiwork: { error_codes: { unit_test_global_fallback: { description: 'Invalid request' } } })

        expect(definition.description(locale_key: 'api/v1')).to eq('Invalid request')
      end
    end

    context 'without locale_key' do
      it 'returns the global translation' do
        definition = described_class.new(attach_path: false, key: :unit_test_global, status: 400)
        I18n.backend.store_translations(:en, apiwork: { error_codes: { unit_test_global: { description: 'Invalid request' } } })

        expect(definition.description).to eq('Invalid request')
      end

      it 'returns the titleized key' do
        definition = described_class.new(attach_path: false, key: :payment_failed, status: 402)

        expect(definition.description).to eq('Payment Failed')
      end
    end
  end
end
