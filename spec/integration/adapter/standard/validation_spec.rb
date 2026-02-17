# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validation', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }

  describe 'contract validation (400)' do
    it 'returns 400 when required field is missing' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      number_issue = json['issues'].find { |i| i['pointer'] == '/invoice/number' }
      expect(number_issue).to be_present
      expect(number_issue['code']).to eq('field_missing')
    end

    it 'returns field_missing for null required field' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: nil } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      number_issue = json['issues'].find { |issue| issue['pointer'] == '/invoice/number' }
      expect(number_issue).to be_present
      expect(number_issue['code']).to eq('field_missing')
    end

    it 'returns type_invalid for wrong data type' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: 'INV-001', sent: 'not-a-boolean' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      sent_issue = json['issues'].find { |i| i['pointer'] == '/invoice/sent' }
      expect(sent_issue).to be_present
      expect(sent_issue['code']).to eq('type_invalid')
    end

    it 'returns all validation errors at once' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { sent: 'not-a-boolean' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues'].length).to be >= 2

      pointers = json['issues'].map { |i| i['pointer'] }
      expect(pointers).to include('/invoice/number')
      expect(pointers).to include('/invoice/sent')
    end

    it 'returns 400 when body is empty' do
      post '/api/v1/invoices', as: :json, params: {}

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues']).not_to be_empty
    end
  end

  describe 'model validation (422)' do
    it 'returns 422 when model validation fails on empty string' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: '' } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'error response format' do
    it 'returns consistent error structure with required fields' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].first
      expect(issue).to have_key('code')
      expect(issue).to have_key('detail')
      expect(issue).to have_key('pointer')
      expect(issue).to have_key('path')
      expect(issue).to have_key('meta')
    end

    it 'uses JSON pointer format for field paths' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id } }

      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['pointer'] == '/invoice/number' }

      expect(issue['pointer']).to eq('/invoice/number')
      expect(issue['path']).to eq(%w[invoice number])
    end
  end

  describe 'update validation' do
    let!(:invoice) { Invoice.create!(customer: customer, number: 'INV-001') }

    it 'does not update record when model validation fails' do
      patch "/api/v1/invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { number: '' } }

      expect(response).to have_http_status(:unprocessable_content)

      invoice.reload
      expect(invoice.number).to eq('INV-001')
    end

    it 'returns type_invalid on update with wrong data type' do
      patch "/api/v1/invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { sent: 'invalid' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      sent_issue = json['issues'].find { |i| i['pointer'] == '/invoice/sent' }
      expect(sent_issue).to be_present
      expect(sent_issue['code']).to eq('type_invalid')
    end

    it 'updates only provided fields on valid partial update' do
      patch "/api/v1/invoices/#{invoice.id}",
            as: :json,
            params: { invoice: { number: 'INV-002' } }

      expect(response).to have_http_status(:ok)

      invoice.reload
      expect(invoice.number).to eq('INV-002')
    end
  end

  describe 'nested attribute validation' do
    it 'returns error for invalid nested item' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               items: [{ description: '' }],
               number: 'INV-001',
             },
           }

      expect(response.status).to be_between(400, 422)
    end
  end
end
