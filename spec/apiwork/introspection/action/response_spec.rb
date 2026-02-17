# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Action::Response do
  describe '#body' do
    it 'returns the body' do
      response = described_class.new(
        body: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string },
        no_content: false,
      )

      expect(response.body).to be_a(Apiwork::Introspection::Param::String)
    end

    it 'returns nil when not set' do
      response = described_class.new(body: nil, no_content: true)

      expect(response.body).to be_nil
    end
  end

  describe '#body?' do
    it 'returns true when body' do
      response = described_class.new(
        body: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string },
        no_content: false,
      )

      expect(response.body?).to be(true)
    end

    it 'returns false when not body' do
      response = described_class.new(body: nil, no_content: true)

      expect(response.body?).to be(false)
    end
  end

  describe '#no_content?' do
    it 'returns true when no content' do
      response = described_class.new(body: nil, no_content: true)

      expect(response.no_content?).to be(true)
    end

    it 'returns false when not no content' do
      response = described_class.new(body: nil, no_content: false)

      expect(response.no_content?).to be(false)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      response = described_class.new(body: nil, no_content: true)

      expect(response.to_h).to eq(
        {
          body: nil,
          no_content: true,
        },
      )
    end
  end
end
