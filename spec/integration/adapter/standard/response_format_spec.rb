# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Response format', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:invoice2) { Invoice.create!(customer: customer1, due_on: 2.days.from_now, number: 'INV-002', status: :sent) }

  describe 'GET /api/v1/invoices/:id' do
    it 'wraps response in singular root key' do
      get "/api/v1/invoices/#{invoice1.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('invoice')
      expect(body['invoice']['number']).to eq('INV-001')
    end
  end

  describe 'GET /api/v1/invoices' do
    it 'wraps response in plural root key' do
      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('invoices')
      expect(body['invoices'].length).to eq(2)
    end

    it 'includes pagination metadata in collection response' do
      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('pagination')
      expect(body['pagination']).to have_key('current')
      expect(body['pagination']).to have_key('total')
      expect(body['pagination']).to have_key('items')
    end

    it 'returns empty array for empty collection' do
      Invoice.destroy_all

      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices']).to eq([])
    end
  end

  describe 'GET /api/v1/receipts/:id' do
    it 'wraps response in custom root key' do
      get "/api/v1/receipts/#{invoice1.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('receipt')
      expect(body).not_to have_key('invoice')
      expect(body['receipt']['number']).to eq('INV-001')
    end
  end

  describe 'GET /api/v1/receipts' do
    it 'wraps collection in custom plural root key' do
      get '/api/v1/receipts'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body).to have_key('receipts')
      expect(body).not_to have_key('invoices')
    end
  end

  describe 'GET /api/v2/customer-addresses' do
    let!(:address1) do
      Address.create!(city: 'Stockholm', country: 'SE', customer: customer1, street: '123 Main St', zip: '111 22')
    end

    it 'responds to kebab-case path' do
      get '/api/v2/customer-addresses'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['addresses'].length).to eq(1)
    end

    it 'applies camelCase key format' do
      get '/api/v2/customer-addresses'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['addresses'].first).to have_key('createdAt')
      expect(body['addresses'].first).to have_key('updatedAt')
    end
  end

  describe 'GET /api/v2/customer-addresses/:id' do
    let!(:address1) do
      Address.create!(city: 'Stockholm', country: 'SE', customer: customer1, street: '123 Main St', zip: '111 22')
    end

    it 'responds to kebab-case show path' do
      get "/api/v2/customer-addresses/#{address1.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['address']['city']).to eq('Stockholm')
    end
  end

  describe 'DELETE /api/v2/customer-addresses/:id' do
    let!(:address1) do
      Address.create!(city: 'Stockholm', country: 'SE', customer: customer1, street: '123 Main St', zip: '111 22')
    end

    it 'responds to kebab-case destroy path' do
      delete "/api/v2/customer-addresses/#{address1.id}"

      expect(response).to have_http_status(:no_content)
    end
  end
end
