# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cursor pagination', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001', status: :draft) }

  before do
    25.times do |i|
      Activity.create!(
        action: "action_#{format('%03d', i + 1)}",
        created_at: (25 - i).days.ago,
        read: i.even?,
        target: invoice1,
      )
    end
  end

  describe 'GET /api/v1/activities' do
    it 'returns first page without cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(10)
      expect(json['pagination']['prev']).to be_nil
    end

    it 'returns next page with after cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']
      first_page_ids = json['activities'].map { |a| a['id'] }

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      second_page_ids = json['activities'].map { |a| a['id'] }
      expect(second_page_ids).not_to include(*first_page_ids)
      expect(json['activities'].length).to eq(10)
    end

    it 'returns prev page with before cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }
      json = JSON.parse(response.body)
      prev_cursor = json['pagination']['prev']

      get '/api/v1/activities', params: { page: { before: prev_cursor, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(10)
    end

    it 'returns next as null on last page' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)

      get '/api/v1/activities', params: { page: { after: json['pagination']['next'], size: 10 } }
      json = JSON.parse(response.body)

      get '/api/v1/activities', params: { page: { after: json['pagination']['next'], size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(5)
      expect(json['pagination']['next']).to be_nil
    end

    it 'returns prev as null on first page' do
      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['prev']).to be_nil
    end

    context 'with filtering' do
      it 'returns only matching records' do
        get '/api/v1/activities',
            params: {
              filter: { read: { eq: true } },
              page: { size: 5 },
            }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['activities'].length).to eq(5)
        json['activities'].each do |activity|
          expect(activity['read']).to be(true)
        end
      end
    end

    context 'with invalid cursor' do
      it 'returns error for garbage after cursor' do
        get '/api/v1/activities', params: { page: { after: 'not-a-valid-cursor', size: 10 } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'value_invalid' }
        expect(issue['path']).to eq(%w[page after])
      end

      it 'returns error for garbage before cursor' do
        get '/api/v1/activities', params: { page: { before: '!!!garbage!!!', size: 10 } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'value_invalid' }
        expect(issue['path']).to eq(%w[page before])
      end
    end

    context 'with size exceeding max' do
      it 'returns error for size above max_size' do
        get '/api/v1/activities', params: { page: { size: 10_000 } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'number_too_large' }
        expect(issue).to be_present
      end
    end
  end
end
