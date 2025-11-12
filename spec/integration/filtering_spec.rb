# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filtering API', type: :request do
  let!(:post1) { Post.create!(title: 'First Post', body: 'Rails tutorial', published: true, created_at: 3.days.ago) }
  let!(:post2) { Post.create!(title: 'Second Post', body: 'Ruby guide', published: false, created_at: 2.days.ago) }
  let!(:post3) { Post.create!(title: 'Third Post', body: 'Rails advanced', published: true, created_at: 1.hour.ago) }

  describe 'GET /api/v1/posts with filters' do
    it 'filters by exact match' do
      get '/api/v1/posts', params: { filter: { title: { eq: 'First Post' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('First Post')
    end

    it 'filters by contains' do
      get '/api/v1/posts', params: { filter: { body: { contains: 'Rails' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to include('First Post', 'Third Post')
    end

    it 'filters by boolean value' do
      get '/api/v1/posts', params: { filter: { published: { eq: true } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      json['posts'].each do |post|
        expect(post['published']).to eq(true)
      end
    end

    it 'filters by greater than' do
      get '/api/v1/posts', params: { filter: { created_at: { gt: 1.day.ago.iso8601 } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Third Post')
    end

    it 'filters by less than or equal' do
      get '/api/v1/posts', params: { filter: { created_at: { lte: 1.day.ago.iso8601 } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to include('First Post', 'Second Post')
    end

    it 'filters by in collection' do
      get '/api/v1/posts', params: { filter: { id: { in: [post1.id, post3.id] } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      ids = json['posts'].map { |p| p['id'] }
      expect(ids).to match_array([post1.id, post3.id])
    end

    it 'filters by not equal using _not operator' do
      get '/api/v1/posts', params: { filter: { _not: { title: { eq: 'First Post' } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to include('Second Post', 'Third Post')
      expect(titles).not_to include('First Post')
    end

    it 'combines multiple filters with AND logic' do
      get '/api/v1/posts', params: {
        filter: {
          published: { eq: true },
          body: { contains: 'Rails' }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      json['posts'].each do |post|
        expect(post['published']).to eq(true)
        expect(post['body']).to include('Rails')
      end
    end

    it 'returns empty array when no matches found' do
      get '/api/v1/posts', params: { filter: { title: { eq: 'Nonexistent' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts']).to eq([])
    end

    it 'handles invalid filter field gracefully' do
      get '/api/v1/posts', params: { filter: { invalid_field: { eq: 'value' } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(false)
      expect(json['errors']).to be_present
    end

    it 'handles invalid operator gracefully' do
      get '/api/v1/posts', params: { filter: { title: { invalid_op: 'value' } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(false)
      expect(json['errors']).to be_present
    end
  end
end
