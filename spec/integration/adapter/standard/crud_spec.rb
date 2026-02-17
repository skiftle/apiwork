# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'CRUD endpoints', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }

  describe 'GET /api/v1/invoices' do
    it 'returns a collection with response envelope' do
      Invoice.create!(customer:, number: 'INV-001')

      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices']).to be_an(Array)
      numbers = json['invoices'].map { |i| i['number'] }
      expect(numbers).to include('INV-001')
    end
  end

  describe 'GET /api/v1/invoices/:id' do
    it 'returns a single invoice with all attributes' do
      invoice = Invoice.create!(customer:, number: 'INV-001', sent: true)

      get "/api/v1/invoices/#{invoice.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['id']).to eq(invoice.id)
      expect(json['invoice']['number']).to eq('INV-001')
      expect(json['invoice']['sent']).to be(true)
    end

    it 'returns 404 for missing invoice' do
      get '/api/v1/invoices/99999'

      expect(response).to have_http_status(:not_found)
    end

    it 'returns error in issues format' do
      get '/api/v1/invoices/99999'

      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues'].first['code']).to eq('not_found')
    end
  end

  describe 'POST /api/v1/invoices' do
    it 'creates an invoice and returns serialized resource' do
      expect do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer.id, number: 'INV-001' } }
      end.to change(Invoice, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['invoice']['number']).to eq('INV-001')
    end

    it 'returns validation errors for missing required fields' do
      expect do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer.id } }
      end.not_to change(Invoice, :count)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_present
    end
  end

  describe 'PATCH /api/v1/invoices/:id' do
    it 'updates an invoice' do
      invoice = Invoice.create!(customer:, number: 'INV-001', sent: false)

      patch "/api/v1/invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { number: 'INV-002', sent: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['number']).to eq('INV-002')
      expect(json['invoice']['sent']).to be(true)
      invoice.reload
      expect(invoice.number).to eq('INV-002')
    end

    it 'returns 404 for missing invoice' do
      patch '/api/v1/invoices/99999',
            as: :json,
            params: { invoice: { number: 'INV-002' } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/invoices/:id' do
    it 'deletes the resource' do
      invoice = Invoice.create!(customer:, number: 'INV-001')

      expect do
        delete "/api/v1/invoices/#{invoice.id}"
      end.to change(Invoice, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for missing invoice' do
      delete '/api/v1/invoices/99999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'JSON column support' do
    it 'accepts JSON data on create' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               metadata: { 'priority' => 'high', 'tags' => %w[billing urgent] },
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['invoice']['metadata']).to eq(
        { 'priority' => 'high', 'tags' => %w[billing urgent] },
      )
    end

    it 'returns JSON data on show' do
      invoice = Invoice.create!(
        customer:,
        metadata: { 'version' => 1 },
        number: 'INV-001',
      )

      get "/api/v1/invoices/#{invoice.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['metadata']).to eq({ 'version' => 1 })
    end

    it 'accepts null for JSON columns' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               metadata: nil,
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['invoice']['metadata']).to be_nil
    end
  end
end
