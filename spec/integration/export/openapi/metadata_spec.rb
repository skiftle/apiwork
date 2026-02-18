# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI metadata generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  describe 'OpenAPI version' do
    it 'generates version 3.1.0' do
      expect(spec[:openapi]).to eq('3.1.0')
    end
  end

  describe 'Info block' do
    it 'generates API title' do
      expect(spec[:info][:title]).to eq('Billing API')
    end

    it 'generates API version' do
      expect(spec[:info][:version]).to eq('1.0.0')
    end

    it 'generates API summary' do
      expect(spec[:info][:summary]).to eq('A billing API for Apiwork')
    end

    it 'generates API description' do
      expect(spec[:info][:description]).to eq('Dummy billing API for the Apiwork gem')
    end

    it 'generates terms of service' do
      expect(spec[:info][:termsOfService]).to eq('https://example.com/terms')
    end
  end

  describe 'Contact info' do
    it 'generates contact name' do
      expect(spec[:info][:contact][:name]).to eq('API Support')
    end

    it 'generates contact email' do
      expect(spec[:info][:contact][:email]).to eq('support@example.com')
    end

    it 'generates contact URL' do
      expect(spec[:info][:contact][:url]).to eq('https://example.com/support')
    end
  end

  describe 'License info' do
    it 'generates license name' do
      expect(spec[:info][:license][:name]).to eq('MIT')
    end

    it 'generates license URL' do
      expect(spec[:info][:license][:url]).to eq('https://opensource.org/licenses/MIT')
    end
  end

  describe 'Servers array' do
    it 'generates two servers' do
      expect(spec[:servers].length).to eq(2)
    end

    it 'generates production server' do
      expect(spec[:servers][0][:url]).to eq('https://api.example.com')
      expect(spec[:servers][0][:description]).to eq('Production')
    end

    it 'generates staging server' do
      expect(spec[:servers][1][:url]).to eq('https://staging-api.example.com')
      expect(spec[:servers][1][:description]).to eq('Staging')
    end
  end

  describe 'Top-level structure' do
    it 'includes paths' do
      expect(spec[:paths]).to be_a(Hash)
    end

    it 'includes components' do
      expect(spec[:components]).to be_a(Hash)
      expect(spec[:components][:schemas]).to be_a(Hash)
    end
  end
end
