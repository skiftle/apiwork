# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Action::Request do
  describe '#description' do
    it 'returns the description' do
      request = described_class.new(
        body: {},
        description: 'The invoice to create',
        query: {},
      )

      expect(request.description).to eq('The invoice to create')
    end

    it 'returns nil when not set' do
      request = described_class.new(body: {}, description: nil, query: {})

      expect(request.description).to be_nil
    end
  end

  describe '#body' do
    it 'returns the body' do
      request = described_class.new(
        body: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        description: nil,
        query: {},
      )

      expect(request.body[:title]).to be_a(Apiwork::Introspection::Param::String)
    end
  end

  describe '#body?' do
    it 'returns true when body' do
      request = described_class.new(
        body: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        description: nil,
        query: {},
      )

      expect(request.body?).to be(true)
    end

    it 'returns false when not body' do
      request = described_class.new(body: {}, description: nil, query: {})

      expect(request.body?).to be(false)
    end
  end

  describe '#query' do
    it 'returns the query' do
      request = described_class.new(
        body: {},
        description: nil,
        query: { page: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: true, type: :integer } },
      )

      expect(request.query[:page]).to be_a(Apiwork::Introspection::Param::Integer)
    end
  end

  describe '#query?' do
    it 'returns true when query' do
      request = described_class.new(
        body: {},
        description: nil,
        query: { page: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: true, type: :integer } },
      )

      expect(request.query?).to be(true)
    end

    it 'returns false when not query' do
      request = described_class.new(body: {}, description: nil, query: {})

      expect(request.query?).to be(false)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      request = described_class.new(body: {}, description: nil, query: {})

      expect(request.to_h).to eq(
        {
          body: {},
          description: nil,
          query: {},
        },
      )
    end
  end
end
