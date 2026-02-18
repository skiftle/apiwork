# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested resources', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001', status: :draft) }
  let!(:invoice2) { Invoice.create!(customer: customer1, number: 'INV-002', status: :sent) }
  let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
  let!(:item2) { Item.create!(description: 'Software license', invoice: invoice1, quantity: 1, unit_price: 500.00) }
  let!(:item3) { Item.create!(description: 'Support contract', invoice: invoice2, quantity: 1, unit_price: 200.00) }

  describe 'GET /api/v1/invoices/:invoice_id/items' do
    it 'returns items scoped to parent invoice' do
      get "/api/v1/invoices/#{invoice1.id}/items"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['items'].length).to eq(2)
      descriptions = json['items'].map { |i| i['description'] }
      expect(descriptions).to contain_exactly('Consulting hours', 'Software license')
    end

    context 'when invoice has no items' do
      it 'returns empty array' do
        empty_invoice = Invoice.create!(customer: customer1, number: 'INV-003')

        get "/api/v1/invoices/#{empty_invoice.id}/items"

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['items']).to eq([])
      end
    end
  end

  describe 'GET /api/v1/invoices/:invoice_id/items/:id' do
    it 'returns the item scoped to parent invoice' do
      get "/api/v1/invoices/#{invoice1.id}/items/#{item1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['item']['id']).to eq(item1.id)
      expect(json['item']['description']).to eq('Consulting hours')
    end

    it 'returns 404 for item from different invoice' do
      get "/api/v1/invoices/#{invoice2.id}/items/#{item1.id}"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 for nonexistent item' do
      get "/api/v1/invoices/#{invoice1.id}/items/99999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/invoices/:invoice_id/items' do
    it 'creates the item under parent invoice' do
      expect do
        post "/api/v1/invoices/#{invoice1.id}/items",
             as: :json,
             params: {
               item: {
                 description: 'Consulting hours',
                 invoice_id: invoice1.id,
                 quantity: 5,
                 unit_price: 200.00,
               },
             }
      end.to change(Item, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['item']['description']).to eq('Consulting hours')
      expect(Item.last.invoice_id).to eq(invoice1.id)
    end
  end

  describe 'PATCH /api/v1/invoices/:invoice_id/items/:id' do
    it 'updates an item within the parent invoice scope' do
      patch "/api/v1/invoices/#{invoice1.id}/items/#{item1.id}",
            as: :json,
            params: { item: { description: 'Updated hours', invoice_id: invoice1.id, quantity: 20 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['item']['description']).to eq('Updated hours')
    end

    it 'returns 404 for item from different invoice' do
      patch "/api/v1/invoices/#{invoice2.id}/items/#{item1.id}",
            as: :json,
            params: { item: { description: 'Hacked', invoice_id: invoice2.id } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/invoices/:invoice_id/items/:id' do
    it 'deletes an item within the parent invoice scope' do
      expect do
        delete "/api/v1/invoices/#{invoice1.id}/items/#{item1.id}"
      end.to change(Item, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 for item from different invoice' do
      delete "/api/v1/invoices/#{invoice2.id}/items/#{item1.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/items' do
    it 'returns all items without parent scope' do
      get '/api/v1/items'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      descriptions = json['items'].map { |i| i['description'] }
      expect(descriptions).to include('Consulting hours', 'Software license', 'Support contract')
    end
  end
end
