# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::API::Info::Server do
  describe '#initialize' do
    it 'creates with required attributes' do
      server = described_class.new(description: 'Ruby developer', url: 'https://example.com/alice.jpg')

      expect(server.url).to eq('https://example.com/alice.jpg')
      expect(server.description).to eq('Ruby developer')
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      server = described_class.new(description: 'Ruby developer', url: 'https://example.com/alice.jpg')

      expect(server.to_h).to eq(
        {
          description: 'Ruby developer',
          url: 'https://example.com/alice.jpg',
        },
      )
    end
  end
end
