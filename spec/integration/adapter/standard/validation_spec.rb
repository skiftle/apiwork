# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Validation', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }

  describe 'contract validation (400)' do
    describe 'POST /api/v1/invoices' do
      it 'returns error for required field missing' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['pointer'] == '/invoice/number' }
        expect(issue['code']).to eq('field_missing')
      end

      it 'returns error for wrong data type' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id, number: 'INV-001', sent: 'not-a-boolean' } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['pointer'] == '/invoice/sent' }
        expect(issue['code']).to eq('type_invalid')
      end

      it 'returns error for unknown field' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id, number: 'INV-001', unknown_field: 'value' } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'field_unknown' }
        expect(issue['code']).to eq('field_unknown')
      end

      it 'returns multiple errors at once' do
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

      it 'returns field_missing for null required field' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id, number: nil } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['pointer'] == '/invoice/number' }
        expect(issue['code']).to eq('field_missing')
      end

      it 'returns error for empty body' do
        post '/api/v1/invoices', as: :json, params: {}

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues'].length).to be >= 1
      end
    end
  end

  describe 'model validation (422)' do
    describe 'POST /api/v1/invoices' do
      it 'returns unprocessable entity for invalid input' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id, number: '' } }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'error response format' do
    describe 'POST /api/v1/invoices' do
      it 'returns issues array with required fields' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].first
        expect(issue).to have_key('code')
        expect(issue).to have_key('detail')
        expect(issue).to have_key('pointer')
        expect(issue).to have_key('path')
        expect(issue).to have_key('meta')
      end

      it 'formats pointer as JSON pointer path' do
        post '/api/v1/invoices',
             as: :json,
             params: { invoice: { customer_id: customer1.id } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['pointer'] == '/invoice/number' }
        expect(issue['pointer']).to eq('/invoice/number')
        expect(issue['path']).to eq(%w[invoice number])
      end
    end
  end

  describe 'nested error path' do
    describe 'POST /api/v1/invoices' do
      it 'returns error for invalid nested item' do
        post '/api/v1/invoices',
             as: :json,
             params: {
               invoice: {
                 customer_id: customer1.id,
                 items: [{ description: '' }],
                 number: 'INV-001',
               },
             }

        expect(response.status).to be_between(400, 422)
      end
    end
  end

  describe 'update validation' do
    let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001', status: :draft) }

    describe 'PATCH /api/v1/invoices/:id' do
      it 'does not persist changes on model validation failure' do
        patch "/api/v1/invoices/#{invoice1.id}",
              as: :json,
              params: { invoice: { number: '' } }

        expect(response).to have_http_status(:unprocessable_content)
        invoice1.reload
        expect(invoice1.number).to eq('INV-001')
      end

      it 'returns type_invalid on update with wrong data type' do
        patch "/api/v1/invoices/#{invoice1.id}",
              as: :json,
              params: { invoice: { sent: 'invalid' } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['pointer'] == '/invoice/sent' }
        expect(issue['code']).to eq('type_invalid')
      end
    end
  end
end
