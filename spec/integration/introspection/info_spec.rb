# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection info', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:info) { introspection.info }

  describe 'Info metadata' do
    it 'returns title' do
      expect(info.title).to eq('Billing API')
    end

    it 'returns version' do
      expect(info.version).to eq('1.0.0')
    end

    it 'returns summary' do
      expect(info.summary).to eq('A billing API for Apiwork')
    end

    it 'returns description' do
      expect(info.description).to eq('Dummy billing API for the Apiwork gem')
    end

    it 'returns terms of service' do
      expect(info.terms_of_service).to eq('https://example.com/terms')
    end

    it 'returns info as hash with all keys' do
      hash = info.to_h

      expect(hash[:title]).to eq('Billing API')
      expect(hash[:version]).to eq('1.0.0')
      expect(hash[:summary]).to eq('A billing API for Apiwork')
      expect(hash[:description]).to eq('Dummy billing API for the Apiwork gem')
      expect(hash[:terms_of_service]).to eq('https://example.com/terms')
    end
  end

  describe 'Contact' do
    it 'returns contact name' do
      expect(info.contact.name).to eq('API Support')
    end

    it 'returns contact email' do
      expect(info.contact.email).to eq('support@example.com')
    end

    it 'returns contact url' do
      expect(info.contact.url).to eq('https://example.com/support')
    end

    it 'returns contact as hash' do
      hash = info.contact.to_h

      expect(hash[:name]).to eq('API Support')
      expect(hash[:email]).to eq('support@example.com')
      expect(hash[:url]).to eq('https://example.com/support')
    end
  end

  describe 'License' do
    it 'returns license name' do
      expect(info.license.name).to eq('MIT')
    end

    it 'returns license url' do
      expect(info.license.url).to eq('https://opensource.org/licenses/MIT')
    end

    it 'returns license as hash' do
      hash = info.license.to_h

      expect(hash[:name]).to eq('MIT')
      expect(hash[:url]).to eq('https://opensource.org/licenses/MIT')
    end
  end

  describe 'Servers' do
    it 'returns all servers' do
      expect(info.servers.length).to eq(2)
    end

    it 'returns production server' do
      server = info.servers[0]

      expect(server.url).to eq('https://api.example.com')
      expect(server.description).to eq('Production')
    end

    it 'returns staging server' do
      server = info.servers[1]

      expect(server.url).to eq('https://staging-api.example.com')
      expect(server.description).to eq('Staging')
    end

    it 'returns server as hash' do
      hash = info.servers[0].to_h

      expect(hash[:url]).to eq('https://api.example.com')
      expect(hash[:description]).to eq('Production')
    end
  end
end
