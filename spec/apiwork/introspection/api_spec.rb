# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::API do
  describe '#initialize' do
    it 'creates with required attributes' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: {},
        info: nil,
        resources: {},
        types: {},
      )

      expect(api.base_path).to eq('/api/v1')
      expect(api.enums).to eq({})
      expect(api.error_codes).to eq({})
      expect(api.info).to be_nil
      expect(api.resources).to eq({})
      expect(api.types).to eq({})
    end
  end

  describe '#enums' do
    it 'returns the enums' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: { status: { deprecated: false, description: nil, example: nil, values: %w[draft published] } },
        error_codes: {},
        info: nil,
        resources: {},
        types: {},
      )

      expect(api.enums[:status]).to be_a(Apiwork::Introspection::Enum)
    end
  end

  describe '#error_codes' do
    it 'returns the error codes' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: { not_found: { description: 'Resource not found', status: 404 } },
        info: nil,
        resources: {},
        types: {},
      )

      expect(api.error_codes[:not_found]).to be_a(Apiwork::Introspection::ErrorCode)
    end
  end

  describe '#info' do
    it 'returns the info' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: {},
        info: {
          contact: nil,
          description: nil,
          license: nil,
          servers: [],
          summary: nil,
          terms_of_service: nil,
          title: 'First Post',
          version: '1.0.0',
        },
        resources: {},
        types: {},
      )

      expect(api.info).to be_a(Apiwork::Introspection::API::Info)
    end

    it 'returns nil when not set' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: {},
        info: nil,
        resources: {},
        types: {},
      )

      expect(api.info).to be_nil
    end
  end

  describe '#resources' do
    it 'returns the resources' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: {},
        info: nil,
        resources: {
          invoices: { actions: {}, identifier: 'invoices', parent_identifiers: [], path: 'invoices', resources: {} },
        },
        types: {},
      )

      expect(api.resources[:invoices]).to be_a(Apiwork::Introspection::API::Resource)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: {},
        info: nil,
        resources: {},
        types: {},
      )

      expect(api.to_h).to eq(
        {
          base_path: '/api/v1',
          enums: {},
          error_codes: {},
          info: nil,
          resources: {},
          types: {},
        },
      )
    end
  end

  describe '#types' do
    it 'returns the types' do
      api = described_class.new(
        base_path: '/api/v1',
        enums: {},
        error_codes: {},
        info: nil,
        resources: {},
        types: {
          invoice: {
            deprecated: false,
            description: nil,
            discriminator: nil,
            example: nil,
            extends: [],
            shape: {},
            type: :object,
            variants: [],
          },
        },
      )

      expect(api.types[:invoice]).to be_a(Apiwork::Introspection::Type)
    end
  end
end
