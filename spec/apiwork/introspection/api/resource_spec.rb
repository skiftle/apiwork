# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::API::Resource do
  describe '#actions' do
    it 'returns the actions' do
      resource = described_class.new(
        actions: {
          show: {
            deprecated: false,
            description: nil,
            method: :get,
            operation_id: nil,
            path: '/invoices/:id',
            raises: [],
            request: { body: {}, query: {} },
            response: { body: nil, no_content: false },
            summary: nil,
            tags: [],
          },
        },
        identifier: 'invoices',
        parent_identifiers: [],
        path: 'invoices',
        resources: {},
      )

      expect(resource.actions[:show]).to be_a(Apiwork::Introspection::Action)
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      resource = described_class.new(
        actions: {},
        identifier: 'invoices',
        parent_identifiers: %w[customers],
        path: 'invoices',
        resources: {},
      )

      expect(resource.identifier).to eq('invoices')
      expect(resource.path).to eq('invoices')
      expect(resource.parent_identifiers).to eq(%w[customers])
    end
  end

  describe '#resources' do
    it 'returns the resources' do
      resource = described_class.new(
        actions: {},
        identifier: 'invoices',
        parent_identifiers: [],
        path: 'invoices',
        resources: {
          items: { actions: {}, identifier: 'items', parent_identifiers: %w[invoices], path: 'items', resources: {} },
        },
      )

      expect(resource.resources[:items]).to be_a(described_class)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      resource = described_class.new(
        actions: {},
        identifier: 'invoices',
        parent_identifiers: [],
        path: 'invoices',
        resources: {},
      )

      expect(resource.to_h).to eq(
        {
          actions: {},
          identifier: 'invoices',
          parent_identifiers: [],
          path: 'invoices',
          resources: {},
        },
      )
    end
  end
end
