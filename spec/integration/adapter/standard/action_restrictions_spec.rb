# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Action restrictions', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001', status: :draft) }
  let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 1, unit_price: 100.00) }

  describe 'restricted_invoices with only: [:index, :show]' do
    it 'returns the collection on index' do
      get '/api/v1/restricted_invoices'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('invoices')
    end

    it 'returns the invoice on show' do
      get "/api/v1/restricted_invoices/#{invoice1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['number']).to eq('INV-001')
    end

    it 'returns 404 on create' do
      post '/api/v1/restricted_invoices',
           as: :json,
           params: { invoice: { customer_id: customer1.id, number: 'INV-002' } }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 on update' do
      patch "/api/v1/restricted_invoices/#{invoice1.id}",
            as: :json,
            params: { invoice: { number: 'INV-002' } }

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 on destroy' do
      delete "/api/v1/restricted_invoices/#{invoice1.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'safe_items with except: [:destroy]' do
    it 'returns 404 on destroy' do
      delete "/api/v1/safe_items/#{item1.id}"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns the collection on index' do
      get '/api/v1/safe_items'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('items')
    end

    it 'returns the item on show' do
      get "/api/v1/safe_items/#{item1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['item']['description']).to eq('Consulting hours')
    end

    it 'creates the item' do
      post '/api/v1/safe_items',
           as: :json,
           params: {
             item: {
               description: 'Consulting hours',
               invoice_id: invoice1.id,
               quantity: 5,
               unit_price: 200.00,
             },
           }

      expect(response).to have_http_status(:created)
    end

    it 'updates the item' do
      patch "/api/v1/safe_items/#{item1.id}",
            as: :json,
            params: {
              item: {
                description: 'Updated hours',
                invoice_id: invoice1.id,
              },
            }

      expect(response).to have_http_status(:ok)
    end
  end
end
