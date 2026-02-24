# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Info::Contact do
  describe '#email' do
    it 'returns the email' do
      contact = described_class.new
      contact.email 'alice@example.com'

      expect(contact.email).to eq('alice@example.com')
    end

    it 'returns nil when not set' do
      contact = described_class.new

      expect(contact.email).to be_nil
    end
  end

  describe '#name' do
    it 'returns the name' do
      contact = described_class.new
      contact.name 'Alice'

      expect(contact.name).to eq('Alice')
    end

    it 'returns nil when not set' do
      contact = described_class.new

      expect(contact.name).to be_nil
    end
  end

  describe '#url' do
    it 'returns the URL' do
      contact = described_class.new
      contact.url 'https://example.com/support'

      expect(contact.url).to eq('https://example.com/support')
    end

    it 'returns nil when not set' do
      contact = described_class.new

      expect(contact.url).to be_nil
    end
  end
end
