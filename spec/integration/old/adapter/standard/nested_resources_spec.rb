# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested resources', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice) { Invoice.create!(customer:, number: 'INV-001') }
  let!(:other_invoice) { Invoice.create!(customer:, number: 'INV-002') }
  let!(:item) { Item.create!(invoice:, description: 'Consulting hours', quantity: 10, unit_price: 150.00) }
  let!(:other_item) { Item.create!(description: 'Travel expenses', invoice: other_invoice, quantity: 1, unit_price: 500.00) }

  describe 'GET /api/v1/invoices/:invoice_id/items' do
    it 'returns items scoped to the parent invoice' do
      get "/api/v1/invoices/#{invoice.id}/items"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['items'].length).to eq(1)
      expect(json['items'].first['description']).to eq('Consulting hours')
    end

    it 'returns different items for different invoices' do
      get "/api/v1/invoices/#{other_invoice.id}/items"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['items'].length).to eq(1)
      expect(json['items'].first['description']).to eq('Travel expenses')
    end

    it 'returns empty array for invoice with no items' do
      empty_invoice = Invoice.create!(customer:, number: 'INV-003')

      get "/api/v1/invoices/#{empty_invoice.id}/items"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['items']).to eq([])
    end
  end

  describe 'GET /api/v1/invoices/:invoice_id/items/:id' do
    it 'returns a specific item from the parent invoice' do
      get "/api/v1/invoices/#{invoice.id}/items/#{item.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['item']['id']).to eq(item.id)
      expect(json['item']['description']).to eq('Consulting hours')
    end

    it 'returns 404 if item belongs to different invoice' do
      get "/api/v1/invoices/#{other_invoice.id}/items/#{item.id}"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if item does not exist' do
      get "/api/v1/invoices/#{invoice.id}/items/99999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/invoices/:invoice_id/items' do
    it 'creates an item associated with the parent invoice' do
      post "/api/v1/invoices/#{invoice.id}/items",
           as: :json,
           params: {
             item: {
               description: 'Consulting hours',
               invoice_id: invoice.id,
               quantity: 5,
               unit_price: 200.00,
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['item']['description']).to eq('Consulting hours')

      created_item = Item.find(json['item']['id'])
      expect(created_item.invoice_id).to eq(invoice.id)
    end
  end

  describe 'PATCH /api/v1/invoices/:invoice_id/items/:id' do
    it 'updates an item within the parent invoice scope' do
      patch "/api/v1/invoices/#{invoice.id}/items/#{item.id}",
            as: :json,
            params: {
              item: {
                description: 'Updated hours',
                invoice_id: invoice.id,
                quantity: 20,
              },
            }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['item']['description']).to eq('Updated hours')
    end

    it 'returns 404 if item belongs to different invoice' do
      patch "/api/v1/invoices/#{other_invoice.id}/items/#{item.id}",
            as: :json,
            params: { item: { description: 'Hacked', invoice_id: other_invoice.id } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/invoices/:invoice_id/items/:id' do
    it 'deletes an item within the parent invoice scope' do
      expect do
        delete "/api/v1/invoices/#{invoice.id}/items/#{item.id}"
      end.to change(Item, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 404 if item belongs to different invoice' do
      delete "/api/v1/invoices/#{other_invoice.id}/items/#{item.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Non-nested routes coexistence' do
    it 'standalone items endpoint returns all items' do
      get '/api/v1/items'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      descriptions = json['items'].map { |i| i['description'] }
      expect(descriptions).to include('Consulting hours', 'Travel expenses')
    end

    it 'nested items endpoint returns scoped items' do
      get "/api/v1/invoices/#{invoice.id}/items"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['items'].length).to eq(1)
    end
  end
end
