# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Info::Server do
  describe '#description' do
    it 'returns the description' do
      server = described_class.new
      server.description 'Production'

      expect(server.description).to eq('Production')
    end

    it 'returns nil when not set' do
      server = described_class.new

      expect(server.description).to be_nil
    end
  end

  describe '#url' do
    it 'returns the URL' do
      server = described_class.new
      server.url 'https://example.com'

      expect(server.url).to eq('https://example.com')
    end

    it 'returns nil when not set' do
      server = described_class.new

      expect(server.url).to be_nil
    end
  end
end
