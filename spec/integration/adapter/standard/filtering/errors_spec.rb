# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filtering errors', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }

  describe 'GET /api/v1/invoices' do
    context 'with unknown field' do
      it 'returns error for unknown filter field' do
        get '/api/v1/invoices', params: { filter: { nonexistent: { eq: 'value' } } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'field_unknown' }
        expect(issue).to be_present
      end
    end

    context 'with invalid operator' do
      it 'returns error for invalid operator' do
        get '/api/v1/invoices', params: { filter: { number: { invalid_op: 'value' } } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'field_unknown' }
        expect(issue['path']).to eq(%w[filter number invalid_op])
      end
    end

    context 'with null on non-nullable field' do
      it 'returns error for null on non-nullable field' do
        get '/api/v1/invoices', params: { filter: { number: { null: true } } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'field_unknown' }
        expect(issue['path']).to eq(%w[filter number null])
      end
    end

    context 'with type mismatch' do
      it 'returns error for string value on integer field' do
        get '/api/v1/invoices', params: { filter: { id: { eq: 'not_a_number' } } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues']).to be_an(Array)
        expect(json['issues'].length).to be >= 1
      end
    end
  end
end
