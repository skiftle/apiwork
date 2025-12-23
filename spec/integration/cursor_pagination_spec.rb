# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cursor Pagination API', type: :request do
  before do
    25.times do |i|
      Activity.create!(
        action: "action_#{i + 1}",
        target_type: 'Post',
        target_id: i + 1,
        read: i.even?,
        created_at: (25 - i).days.ago
      )
    end
  end

  describe 'GET /api/v1/activities with cursor pagination' do
    it 'returns first page without cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(10)
      expect(json['pagination']['next']).to be_present
      expect(json['pagination']['prev']).to be_nil
    end

    it 'navigates forward with after cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']
      first_page_ids = json['activities'].map { |a| a['id'] }

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['activities'].length).to eq(10)

      second_page_ids = json['activities'].map { |a| a['id'] }
      expect(second_page_ids).not_to include(*first_page_ids)
      expect(second_page_ids.min).to be > first_page_ids.max
    end

    it 'navigates backward with before cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }
      json = JSON.parse(response.body)
      prev_cursor = json['pagination']['prev']
      second_page_ids = json['activities'].map { |a| a['id'] }

      get '/api/v1/activities', params: { page: { before: prev_cursor, size: 10 } }

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      back_page_ids = json['activities'].map { |a| a['id'] }
      expect(back_page_ids.max).to be < second_page_ids.min
    end

    it 'returns null next_cursor on last page' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }

      json = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(json['activities'].length).to eq(5)
      expect(json['pagination']['next']).to be_nil
    end

    it 'handles different page sizes' do
      get '/api/v1/activities', params: { page: { size: 5 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(5)
      expect(json['pagination']['next']).to be_present
    end

    it 'uses default page size when not specified' do
      get '/api/v1/activities'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(20)
      expect(json['pagination']).to be_present
    end

    it 'combines cursor pagination with filtering' do
      get '/api/v1/activities', params: {
        filter: { read: { eq: true } },
        page: { size: 5 }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(5)
      json['activities'].each do |activity|
        expect(activity['read']).to be(true)
      end
    end

    it 'returns empty array when no results' do
      Activity.destroy_all

      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities']).to eq([])
      expect(json['pagination']['next']).to be_nil
      expect(json['pagination']['prev']).to be_nil
    end

    it 'returns consistent ordering by id' do
      get '/api/v1/activities', params: { page: { size: 25 } }

      json = JSON.parse(response.body)
      ids = json['activities'].map { |a| a['id'] }
      expect(ids).to eq(ids.sort)
    end

    it 'handles invalid base64 cursor gracefully' do
      get '/api/v1/activities', params: { page: { after: 'invalid-cursor' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_an(Array)
      expect(json['errors'].first['code']).to eq('cursor_invalid')
    end

    it 'enforces maximum page size' do
      get '/api/v1/activities', params: { page: { size: 10_000 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_an(Array)
      expect(json['errors'].first['code']).to eq('value_invalid')
    end
  end
end
