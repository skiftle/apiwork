# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'path_format configuration', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }

  describe 'API with path_format :kebab' do
    it 'routes to kebab-case paths for index' do
      Address.create!(customer:, city: 'Stockholm', country: 'SE', street: '123 Main St', zip: '11122')

      get '/api/v2/customer-addresses'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['addresses']).to be_an(Array)
    end

    it 'routes to kebab-case paths for show' do
      address = Address.create!(customer:, city: 'Stockholm', country: 'SE', street: '123 Main St', zip: '11122')

      get "/api/v2/customer-addresses/#{address.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['address']['city']).to eq('Stockholm')
    end

    it 'routes to kebab-case paths for destroy' do
      address = Address.create!(customer:, city: 'Stockholm', country: 'SE', street: '123 Main St', zip: '11122')

      delete "/api/v2/customer-addresses/#{address.id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'path_format :kebab combined with key_format :camel' do
    it 'uses camelCase in response attribute keys' do
      Address.create!(customer:, city: 'Stockholm', country: 'SE', street: '123 Main St', zip: '11122')

      get '/api/v2/customer-addresses'

      json = JSON.parse(response.body)
      expect(json['addresses']).to be_an(Array)
      expect(json['addresses'].first).to have_key('createdAt')
      expect(json['addresses'].first).to have_key('updatedAt')
    end
  end

  describe 'path_format in introspection' do
    it 'reflects path_format setting in API introspection' do
      api_class = Apiwork::API.find!('/api/v2')

      expect(api_class.path_format).to eq(:kebab)
    end
  end

  describe 'path_format transforms custom paths' do
    let(:api_class) do
      Class.new(Apiwork::API::Base) do
        mount '/api/v99'
        key_format :camel
        path_format :kebab

        resources :recurring, path: 'recurring_invoices'
      end
    end

    after { Apiwork::API::Registry.unregister('/api/v99') }

    it 'transforms explicit path option' do
      introspection = api_class.introspect
      resource = introspection.resources[:recurring]

      expect(resource.path).to eq('recurring-invoices')
    end

    it 'transforms base_path via transform_path' do
      expect(api_class.transform_path('recurring_invoices')).to eq('recurring-invoices')
    end
  end
end
