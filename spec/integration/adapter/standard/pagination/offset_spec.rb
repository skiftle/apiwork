# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Offset pagination', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }

  before do
    25.times do |i|
      Invoice.create!(
        customer: customer1,
        due_on: (25 - i).days.from_now,
        number: "INV-#{format('%03d', i + 1)}",
        status: i.even? ? :draft : :sent,
      )
    end
  end

  describe 'GET /api/v1/invoices' do
    it 'returns first page with default size' do
      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices'].length).to eq(20)
      expect(body['pagination']['current']).to eq(1)
    end

    it 'returns specific page' do
      get '/api/v1/invoices', params: { page: { number: 2, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices'].length).to eq(10)
      expect(body['pagination']['current']).to eq(2)
    end

    it 'returns pagination metadata' do
      get '/api/v1/invoices', params: { page: { number: 1, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['pagination']['current']).to eq(1)
      expect(body['pagination']['next']).to eq(2)
      expect(body['pagination']['prev']).to be_nil
      expect(body['pagination']['total']).to eq(3)
      expect(body['pagination']['items']).to eq(25)
    end

    it 'returns prev as null on first page' do
      get '/api/v1/invoices', params: { page: { number: 1, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['pagination']['prev']).to be_nil
    end

    it 'returns next as null on last page' do
      get '/api/v1/invoices', params: { page: { number: 3, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['pagination']['next']).to be_nil
      expect(body['invoices'].length).to eq(5)
    end

    it 'returns empty array when out of range' do
      get '/api/v1/invoices', params: { page: { number: 100, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices']).to eq([])
      expect(body['pagination']['total']).to eq(3)
      expect(body['pagination']['items']).to eq(25)
    end

    it 'returns error when page size exceeds max' do
      get '/api/v1/invoices', params: { page: { number: 1, size: 10_000 } }

      expect(response).to have_http_status(:bad_request)
      body = response.parsed_body
      issue = body['issues'].find { |i| i['code'] == 'number_too_large' }
      expect(issue['code']).to eq('number_too_large')
    end

    it 'rejects negative page number' do
      get '/api/v1/invoices', params: { page: { number: -1, size: 10 } }

      expect(response).to have_http_status(:bad_request)
      body = response.parsed_body
      issue = body['issues'].find { |i| i['code'] == 'number_too_small' }
      expect(issue['code']).to eq('number_too_small')
    end

    context 'with filtering' do
      it 'reflects filtered count in pagination metadata' do
        get '/api/v1/invoices',
            params: {
              filter: { status: { eq: 'draft' } },
              page: { number: 1, size: 5 },
            }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(5)
        body['invoices'].each do |invoice|
          expect(invoice['status']).to eq('draft')
        end
        expect(body['pagination']['items']).to eq(13)
      end
    end
  end
end
