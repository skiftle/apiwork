# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom actions', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001', sent: false, status: :draft) }

  describe 'PATCH /api/v1/invoices/:id/send_invoice' do
    it 'updates the invoice with body params' do
      patch "/api/v1/invoices/#{invoice1.id}/send_invoice",
            as: :json,
            params: { message: 'Please review', notify_customer: false, recipient_email: 'billing@acme.com' }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoice']['sent']).to be(true)
      invoice1.reload
      expect(invoice1.sent).to be(true)
    end

    it 'applies default values in custom action body' do
      patch "/api/v1/invoices/#{invoice1.id}/send_invoice",
            as: :json,
            params: { recipient_email: 'billing@acme.com' }

      expect(response).to have_http_status(:ok)
    end

    it 'returns error for unknown field on custom action' do
      patch "/api/v1/invoices/#{invoice1.id}/void",
            as: :json,
            params: { unknown_field: 'value' }

      expect(response).to have_http_status(:bad_request)
      body = response.parsed_body
      issue = body['issues'].find { |i| i['code'] == 'field_unknown' }
      expect(issue['code']).to eq('field_unknown')
    end
  end

  describe 'PATCH /api/v1/invoices/:id/void' do
    it 'updates the invoice without body' do
      patch "/api/v1/invoices/#{invoice1.id}/void", as: :json

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoice']['status']).to eq('void')
      invoice1.reload
      expect(invoice1.void?).to be(true)
    end
  end

  describe 'GET /api/v1/invoices/search' do
    let!(:invoice2) { Invoice.create!(customer: customer1, number: 'INV-002', status: :sent) }

    it 'returns collection with query params' do
      get '/api/v1/invoices/search', params: { q: 'INV-001' }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices'].length).to eq(1)
      expect(body['invoices'][0]['number']).to eq('INV-001')
    end
  end

  describe 'POST /api/v1/invoices/bulk_create' do
    it 'creates multiple records with body params' do
      expect do
        post '/api/v1/invoices/bulk_create',
             as: :json,
             params: {
               invoices: [
                 { customer_id: customer1.id, number: 'INV-002' },
                 { customer_id: customer1.id, number: 'INV-003', sent: true },
               ],
             }
      end.to change(Invoice, :count).by(2)

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['invoices'].length).to eq(2)
    end
  end
end
