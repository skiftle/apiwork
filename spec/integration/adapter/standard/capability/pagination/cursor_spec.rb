# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cursor pagination', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer, number: 'INV-001', status: :draft) }

  before do
    25.times do |index|
      Activity.create!(
        action: "action_#{format('%03d', index + 1)}",
        created_at: (25 - index).days.ago,
        read: index.even?,
        target: invoice1,
      )
    end
  end

  describe 'GET /api/v1/activities' do
    it 'returns first page without cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['activities'].length).to eq(10)
      expect(body['pagination']['prev']).to be_nil
    end

    it 'returns next page with after cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      body = response.parsed_body
      next_cursor = body['pagination']['next']
      first_page_ids = body['activities'].map { |activity| activity['id'] }

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      second_page_ids = body['activities'].map { |activity| activity['id'] }
      expect(second_page_ids).not_to include(*first_page_ids)
      expect(body['activities'].length).to eq(10)
    end

    it 'returns prev page with before cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      body = response.parsed_body
      next_cursor = body['pagination']['next']

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }
      body = response.parsed_body
      prev_cursor = body['pagination']['prev']

      get '/api/v1/activities', params: { page: { before: prev_cursor, size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['activities'].length).to eq(10)
    end

    it 'returns next as null on last page' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      body = response.parsed_body

      get '/api/v1/activities', params: { page: { after: body['pagination']['next'], size: 10 } }
      body = response.parsed_body

      get '/api/v1/activities', params: { page: { after: body['pagination']['next'], size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['activities'].length).to eq(5)
      expect(body['pagination']['next']).to be_nil
    end

    it 'returns prev as null on first page' do
      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['pagination']['prev']).to be_nil
    end

    context 'with filtering' do
      it 'returns only matching records' do
        get '/api/v1/activities',
            params: {
              filter: { read: { eq: true } },
              page: { size: 5 },
            }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['activities'].length).to eq(5)
        body['activities'].each do |activity|
          expect(activity['read']).to be(true)
        end
      end
    end

    context 'with invalid cursor' do
      it 'returns error for garbage after cursor' do
        get '/api/v1/activities', params: { page: { after: 'not-a-valid-cursor', size: 10 } }

        expect(response).to have_http_status(:bad_request)
        body = response.parsed_body
        issue = body['issues'].find { |issue| issue['code'] == 'value_invalid' }
        expect(issue['path']).to eq(%w[page after])
      end

      it 'returns error for garbage before cursor' do
        get '/api/v1/activities', params: { page: { before: '!!!garbage!!!', size: 10 } }

        expect(response).to have_http_status(:bad_request)
        body = response.parsed_body
        issue = body['issues'].find { |issue| issue['code'] == 'value_invalid' }
        expect(issue['path']).to eq(%w[page before])
      end
    end

    context 'with size exceeding max' do
      it 'returns error for size above max_size' do
        get '/api/v1/activities', params: { page: { size: 10_000 } }

        expect(response).to have_http_status(:bad_request)
        body = response.parsed_body
        issue = body['issues'].find { |issue| issue['code'] == 'number_too_large' }
        expect(issue['code']).to eq('number_too_large')
      end
    end
  end
end
