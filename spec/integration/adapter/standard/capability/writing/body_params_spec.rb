# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Body params', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }

  describe 'POST /api/v1/invoices' do
    it 'creates the invoice with writable fields' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               notes: 'Net 30 payment terms',
               number: 'INV-001',
               sent: false,
             },
           }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['invoice']['number']).to eq('INV-001')
      expect(body['invoice']['notes']).to eq('Net 30 payment terms')
      expect(body['invoice']['sent']).to be(false)
    end

    it 'returns error for unknown field in body' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               number: 'INV-001',
               unknown_field: 'value',
             },
           }

      expect(response).to have_http_status(:bad_request)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'field_unknown' }
      expect(issue['code']).to eq('field_unknown')
    end
  end

  describe 'PATCH /api/v1/invoices/:id' do
    let!(:invoice1) do
      Invoice.create!(customer: customer, notes: 'Net 30 payment terms', number: 'INV-001', status: :draft)
    end

    it 'updates only provided fields' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: { invoice: { notes: 'Rush delivery' } }

      expect(response).to have_http_status(:ok)
      invoice1.reload
      expect(invoice1.notes).to eq('Rush delivery')
      expect(invoice1.number).to eq('INV-001')
    end

    it 'returns error for unknown field on update' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: { invoice: { unknown_field: 'value' } }

      expect(response).to have_http_status(:bad_request)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'field_unknown' }
      expect(issue['code']).to eq('field_unknown')
    end
  end

  describe 'POST /api/v1/customers' do
    it 'applies decode transformer on create' do
      post '/api/v1/customers',
           as: :json,
           params: {
             customer: {
               email: 'anna@example.com',
               name: 'Anna Svensson',
               type: 'person',
             },
           }

      expect(response).to have_http_status(:created)
      created_customer = PersonCustomer.last
      expect(created_customer.email).to eq('ANNA@EXAMPLE.COM')
    end
  end
end
