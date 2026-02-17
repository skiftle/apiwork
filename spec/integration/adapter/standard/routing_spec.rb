# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routing DSL overrides', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }

  describe 'Restricted resources with only: [:index, :show]' do
    let!(:invoice) { Invoice.create!(customer:, number: 'INV-001') }

    it 'allows index action' do
      get '/api/v1/restricted_invoices'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('invoices')
    end

    it 'allows show action' do
      get "/api/v1/restricted_invoices/#{invoice.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('invoice')
      expect(json['invoice']['number']).to eq('INV-001')
    end

    it 'restricts create action' do
      post '/api/v1/restricted_invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: 'INV-002' } }

      expect(response).to have_http_status(:not_found)
    end

    it 'restricts update action' do
      patch "/api/v1/restricted_invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { number: 'INV-002' } }

      expect(response).to have_http_status(:not_found)
    end

    it 'restricts destroy action' do
      delete "/api/v1/restricted_invoices/#{invoice.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Resources with except: [:destroy]' do
    let!(:invoice) { Invoice.create!(customer:, number: 'INV-001') }
    let!(:safe_item) { Item.create!(invoice:, description: 'Consulting hours', quantity: 1, unit_price: 100.00) }

    it 'allows index action' do
      get '/api/v1/safe_items'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('items')
    end

    it 'allows show action' do
      get "/api/v1/safe_items/#{safe_item.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('item')
      expect(json['item']['description']).to eq('Consulting hours')
    end

    it 'allows create action' do
      post '/api/v1/safe_items',
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
    end

    it 'allows update action' do
      patch "/api/v1/safe_items/#{safe_item.id}",
            as: :json,
            params: {
              item: {
                description: 'Updated hours',
                invoice_id: invoice.id,
              },
            }

      expect(response).to have_http_status(:ok)
    end

    it 'restricts destroy action' do
      delete "/api/v1/safe_items/#{safe_item.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Custom member and collection actions' do
    let!(:invoice) { Invoice.create!(customer:, number: 'INV-001', sent: false, status: :draft) }

    it 'routes member action send_invoice' do
      patch "/api/v1/invoices/#{invoice.id}/send_invoice"

      expect(response).to have_http_status(:ok)
      invoice.reload
      expect(invoice.sent).to be(true)
    end

    it 'routes member action void' do
      patch "/api/v1/invoices/#{invoice.id}/void"

      expect(response).to have_http_status(:ok)
      invoice.reload
      expect(invoice.status).to eq('void')
    end

    it 'routes collection action search' do
      get '/api/v1/invoices/search', params: { q: 'INV' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices']).to be_an(Array)
    end
  end
end
