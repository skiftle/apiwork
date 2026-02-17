# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Action::Request do
  describe '#body' do
    it 'returns the body' do
      request = described_class.new(
        body: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        query: {},
      )

      expect(request.body[:title]).to be_a(Apiwork::Introspection::Param::String)
    end
  end

  describe '#body?' do
    it 'returns true when body' do
      request = described_class.new(
        body: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        query: {},
      )

      expect(request.body?).to be(true)
    end

    it 'returns false when not body' do
      request = described_class.new(body: {}, query: {})

      expect(request.body?).to be(false)
    end
  end

  describe '#query' do
    it 'returns the query' do
      request = described_class.new(
        body: {},
        query: { page: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: true, type: :integer } },
      )

      expect(request.query[:page]).to be_a(Apiwork::Introspection::Param::Integer)
    end
  end

  describe '#query?' do
    it 'returns true when query' do
      request = described_class.new(
        body: {},
        query: { page: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: true, type: :integer } },
      )

      expect(request.query?).to be(true)
    end

    it 'returns false when not query' do
      request = described_class.new(body: {}, query: {})

      expect(request.query?).to be(false)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      request = described_class.new(body: {}, query: {})

      expect(request.to_h).to eq(
        {
          body: {},
          query: {},
        },
      )
    end
  end
end
