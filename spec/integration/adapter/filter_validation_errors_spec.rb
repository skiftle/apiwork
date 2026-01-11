# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filter and Sort Validation Errors', type: :request do
  describe 'Invalid filter parameters' do
    it 'returns 400 for unknown filter field' do
      get '/api/v1/posts', params: { filter: { unknown_field: 'value' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      expect(json['issues']).not_to be_empty
    end

    it 'returns descriptive error for unknown filter field' do
      get '/api/v1/posts', params: { filter: { nonexistent: 'value' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].first
      expect(issue['code']).to be_present
      expect(issue['detail']).to be_present
    end

    it 'returns 400 for invalid filter operator' do
      get '/api/v1/posts', params: { filter: { title: { invalid_op: 'value' } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
    end
  end

  describe 'Invalid sort parameters' do
    # Sort uses hash format: { field: 'asc' } or { field: 'desc' }
    it 'returns 400 for unknown sort field' do
      get '/api/v1/posts', params: { sort: { unknown_field: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      expect(json['issues']).not_to be_empty
    end

    it 'returns descriptive error for unknown sort field' do
      get '/api/v1/posts', params: { sort: { nonexistent_column: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].first
      expect(issue['code']).to be_present
      expect(issue['detail']).to be_present
    end
  end

  describe 'Valid filter and sort parameters' do
    before do
      Post.create!(published: true, title: 'Alpha Post')
      Post.create!(published: false, title: 'Beta Post')
    end

    it 'accepts valid filter parameters' do
      get '/api/v1/posts', params: { filter: { title: { eq: 'Alpha Post' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(1)
    end

    it 'accepts valid sort parameters with hash format' do
      get '/api/v1/posts', params: { sort: { title: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(titles.sort)
    end

    it 'accepts descending sort with hash format' do
      get '/api/v1/posts', params: { sort: { title: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(titles.sort.reverse)
    end
  end

  describe 'Error response format' do
    it 'returns consistent error format for filter errors' do
      get '/api/v1/posts', params: { filter: { invalid: 'value' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json).to have_key('issues')
      expect(json['issues']).to be_an(Array)

      issue = json['issues'].first
      expect(issue).to have_key('code')
      expect(issue).to have_key('detail')
    end

    it 'returns consistent error format for sort errors' do
      get '/api/v1/posts', params: { sort: { invalid_field: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json).to have_key('issues')
      expect(json['issues']).to be_an(Array)
    end
  end

  describe 'Combined filter and sort errors' do
    it 'returns multiple issues for combined invalid filter and sort' do
      get '/api/v1/posts',
          params: {
            filter: { unknown_filter: 'value' },
            sort: { unknown_sort: 'asc' },
          }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      expect(json['issues'].length).to be >= 2
    end

    it 'returns error for invalid filter even with valid sort' do
      get '/api/v1/posts',
          params: {
            filter: { nonexistent: 'value' },
            sort: { title: 'asc' },
          }

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns error for invalid sort even with valid filter' do
      get '/api/v1/posts',
          params: {
            filter: { title: { eq: 'Test' } },
            sort: { nonexistent: 'asc' },
          }

      expect(response).to have_http_status(:bad_request)
    end
  end
end
