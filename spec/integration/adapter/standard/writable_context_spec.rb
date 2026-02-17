# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Body, Query, and Path Context', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }

  describe 'body context on create' do
    it 'accepts writable fields in body' do
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
      json = JSON.parse(response.body)
      expect(json['invoice']['number']).to eq('INV-001')
      expect(json['invoice']['notes']).to eq('Net 30 payment terms')
    end

    it 'rejects unknown fields in body' do
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
      json = JSON.parse(response.body)

      unknown_issue = json['issues'].find { |issue| issue['code'] == 'field_unknown' }
      expect(unknown_issue).to be_present
    end
  end

  describe 'body context on update' do
    let!(:invoice) do
      Invoice.create!(
        customer: customer,
        notes: 'Original notes',
        number: 'INV-001',
      )
    end

    it 'accepts partial body updates' do
      patch "/api/v1/invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { notes: 'Updated notes' } }

      expect(response).to have_http_status(:ok)

      invoice.reload
      expect(invoice.notes).to eq('Updated notes')
      expect(invoice.number).to eq('INV-001')
    end

    it 'rejects unknown fields in update body' do
      patch "/api/v1/invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { unknown_field: 'value' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      unknown_issue = json['issues'].find { |issue| issue['code'] == 'field_unknown' }
      expect(unknown_issue).to be_present
    end
  end

  describe 'body context on custom member action' do
    let!(:invoice) do
      Invoice.create!(
        customer: customer,
        number: 'INV-001',
        sent: false,
      )
    end

    it 'accepts custom body params defined on action' do
      patch "/api/v1/invoices/#{invoice.id}/send_invoice",
            as: :json,
            params: { message: 'Please review', notify_customer: false }

      expect(response).to have_http_status(:ok)
    end

    it 'rejects unknown body fields on custom action' do
      patch "/api/v1/invoices/#{invoice.id}/void",
            as: :json,
            params: { unknown_field: 'value' }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      unknown_issue = json['issues'].find { |issue| issue['code'] == 'field_unknown' }
      expect(unknown_issue).to be_present
    end

    it 'applies default values in custom action body' do
      patch "/api/v1/invoices/#{invoice.id}/send_invoice",
            as: :json,
            params: {}

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'query context on collection action' do
    let!(:invoice) do
      Invoice.create!(
        customer: customer,
        number: 'INV-001',
      )
    end

    it 'accepts query params on search action' do
      get '/api/v1/invoices/search', params: { q: 'INV-001' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(1)
    end

    it 'applies default query param value when omitted' do
      get '/api/v1/invoices/search'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |i| i['number'] }
      expect(numbers).to include('INV-001')
    end
  end

  describe 'path context' do
    let!(:invoice) do
      Invoice.create!(
        customer: customer,
        number: 'INV-001',
      )
    end

    it 'resolves path parameter for member actions' do
      get "/api/v1/invoices/#{invoice.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['id']).to eq(invoice.id)
    end

    it 'returns 404 for invalid path parameter' do
      get '/api/v1/invoices/99999'

      expect(response).to have_http_status(:not_found)
    end
  end
end
