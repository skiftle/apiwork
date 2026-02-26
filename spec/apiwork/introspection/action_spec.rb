# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Action do
  describe '#initialize' do
    it 'creates with required attributes' do
      action = described_class.new(
        deprecated: false,
        description: 'Ruby developer',
        method: :get,
        operation_id: 'showInvoice',
        path: '/invoices/:id',
        raises: [:not_found],
        request: { body: {}, query: {} },
        response: { body: nil, no_content: false },
        summary: 'Rails tutorial',
        tags: %w[Ruby],
      )

      expect(action.path).to eq('/invoices/:id')
      expect(action.method).to eq(:get)
      expect(action.raises).to eq([:not_found])
      expect(action.summary).to eq('Rails tutorial')
      expect(action.description).to eq('Ruby developer')
      expect(action.tags).to eq(%w[Ruby])
      expect(action.operation_id).to eq('showInvoice')
      expect(action.deprecated?).to be(false)
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      action = described_class.new(
        deprecated: true,
        description: nil,
        method: :get,
        operation_id: nil,
        path: '/invoices/:id',
        raises: [],
        request: { body: {}, query: {} },
        response: { body: nil, no_content: false },
        summary: nil,
        tags: [],
      )

      expect(action.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      action = described_class.new(
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
      )

      expect(action.deprecated?).to be(false)
    end
  end

  describe '#request' do
    it 'returns the request' do
      action = described_class.new(
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
      )

      expect(action.request).to be_a(Apiwork::Introspection::Action::Request)
    end
  end

  describe '#response' do
    it 'returns the response' do
      action = described_class.new(
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
      )

      expect(action.response).to be_a(Apiwork::Introspection::Action::Response)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      action = described_class.new(
        deprecated: false,
        description: nil,
        method: :get,
        operation_id: nil,
        path: '/invoices/:id',
        raises: [],
        request: { body: {}, query: {} },
        response: { body: nil, description: nil, no_content: false },
        summary: nil,
        tags: [],
      )

      expect(action.to_h).to eq(
        {
          deprecated: false,
          description: nil,
          method: :get,
          operation_id: nil,
          path: '/invoices/:id',
          raises: [],
          request: { body: {}, query: {} },
          response: { body: nil, description: nil, no_content: false },
          summary: nil,
          tags: [],
        },
      )
    end
  end
end
