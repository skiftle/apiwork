# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::API::Info::Contact do
  describe '#initialize' do
    it 'creates with required attributes' do
      contact = described_class.new(email: 'alice@example.com', name: 'Alice', url: 'https://example.com/alice.jpg')

      expect(contact.name).to eq('Alice')
      expect(contact.email).to eq('alice@example.com')
      expect(contact.url).to eq('https://example.com/alice.jpg')
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      contact = described_class.new(email: 'alice@example.com', name: 'Alice', url: 'https://example.com/alice.jpg')

      expect(contact.to_h).to eq(
        {
          email: 'alice@example.com',
          name: 'Alice',
          url: 'https://example.com/alice.jpg',
        },
      )
    end
  end
end
