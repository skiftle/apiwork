# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom Actions', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice) do
    Invoice.create!(
      customer: customer,
      number: 'INV-001',
      sent: false,
      status: :draft,
    )
  end

  describe 'Member actions' do
    describe 'PATCH /api/v1/invoices/:id/send_invoice' do
      it 'routes to custom member action and updates state' do
        patch "/api/v1/invoices/#{invoice.id}/send_invoice", as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoice']['id']).to eq(invoice.id)
        expect(json['invoice']['sent']).to be(true)

        invoice.reload
        expect(invoice.sent).to be(true)
      end

      it 'accepts optional body parameters' do
        patch "/api/v1/invoices/#{invoice.id}/send_invoice",
              as: :json,
              params: { message: 'Please pay soon', notify_customer: false }

        expect(response).to have_http_status(:ok)
      end

      it 'returns 404 for nonexistent record' do
        patch '/api/v1/invoices/99999/send_invoice'

        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'PATCH /api/v1/invoices/:id/void' do
      it 'routes to void action and changes status' do
        patch "/api/v1/invoices/#{invoice.id}/void", as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoice']['status']).to eq('void')

        invoice.reload
        expect(invoice.void?).to be(true)
      end
    end
  end

  describe 'Collection actions' do
    describe 'GET /api/v1/invoices/search' do
      let!(:invoice2) do
        Invoice.create!(
          customer: customer,
          notes: 'Quarterly billing',
          number: 'INV-002',
          status: :sent,
        )
      end

      it 'routes to custom collection action with query params' do
        get '/api/v1/invoices/search', params: { q: 'INV-001' }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-001')
      end

      it 'returns all records when query is empty' do
        get '/api/v1/invoices/search'

        json = JSON.parse(response.body)
        numbers = json['invoices'].map { |i| i['number'] }
        expect(numbers).to include('INV-001', 'INV-002')
      end

      it 'returns empty collection for no matches' do
        get '/api/v1/invoices/search', params: { q: 'NONEXISTENT' }

        json = JSON.parse(response.body)
        expect(json['invoices']).to eq([])
      end
    end

    describe 'POST /api/v1/invoices/bulk_create' do
      it 'creates multiple records and returns collection' do
        invoices_params = {
          invoices: [
            { customer_id: customer.id, number: 'BULK-001' },
            { customer_id: customer.id, number: 'BULK-002', sent: true },
          ],
        }

        expect do
          post '/api/v1/invoices/bulk_create', as: :json, params: invoices_params
        end.to change(Invoice, :count).by(2)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
      end

      it 'handles empty array' do
        post '/api/v1/invoices/bulk_create', as: :json, params: { invoices: [] }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['invoices']).to eq([])
      end
    end
  end

  describe 'Standard and custom actions coexist' do
    it 'custom member action does not interfere with standard CRUD' do
      get "/api/v1/invoices/#{invoice.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['sent']).to be(false)

      patch "/api/v1/invoices/#{invoice.id}/send_invoice", as: :json

      expect(response).to have_http_status(:ok)

      get "/api/v1/invoices/#{invoice.id}"

      json = JSON.parse(response.body)
      expect(json['invoice']['sent']).to be(true)
    end
  end
end
