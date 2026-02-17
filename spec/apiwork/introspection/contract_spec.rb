# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Contract do
  describe '#actions' do
    it 'returns the actions' do
      contract = described_class.new(
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
        enums: {},
        types: {},
      )

      expect(contract.actions[:show]).to be_a(Apiwork::Introspection::Action)
    end
  end

  describe '#enums' do
    it 'returns the enums' do
      contract = described_class.new(
        actions: {},
        enums: { status: { deprecated: false, description: nil, example: nil, values: %w[draft published] } },
        types: {},
      )

      expect(contract.enums[:status]).to be_a(Apiwork::Introspection::Enum)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      contract = described_class.new(actions: {}, enums: {}, types: {})

      expect(contract.to_h).to eq(
        {
          actions: {},
          enums: {},
          types: {},
        },
      )
    end
  end

  describe '#types' do
    it 'returns the types' do
      contract = described_class.new(
        actions: {},
        enums: {},
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

      expect(contract.types[:invoice]).to be_a(Apiwork::Introspection::Type)
    end
  end
end
