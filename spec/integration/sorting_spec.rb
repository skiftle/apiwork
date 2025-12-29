# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sorting API', type: :request do
  let!(:post_a) { Post.create!(body: 'Content A', created_at: 3.days.ago, published: true, title: 'Alpha Post') }
  let!(:post_b) { Post.create!(body: 'Content B', created_at: 1.day.ago, published: false, title: 'Beta Post') }
  let!(:post_c) { Post.create!(body: 'Content C', created_at: 2.days.ago, published: true, title: 'Charlie Post') }

  describe 'GET /api/v1/posts with sorting' do
    it 'sorts by title ascending' do
      get '/api/v1/posts', params: { sort: { title: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Alpha Post', 'Beta Post', 'Charlie Post'])
    end

    it 'sorts by title descending' do
      get '/api/v1/posts', params: { sort: { title: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Charlie Post', 'Beta Post', 'Alpha Post'])
    end

    it 'sorts by created_at ascending' do
      get '/api/v1/posts', params: { sort: { created_at: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Alpha Post', 'Charlie Post', 'Beta Post'])
    end

    it 'sorts by created_at descending' do
      get '/api/v1/posts', params: { sort: { created_at: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Beta Post', 'Charlie Post', 'Alpha Post'])
    end

    it 'sorts by boolean field' do
      get '/api/v1/posts', params: { sort: { published: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      published_values = json['posts'].map { |p| p['published'] }
      expect(published_values.first).to be(false)
      expect(published_values.last).to be(true)
    end

    it 'sorts by multiple fields' do
      get '/api/v1/posts', params: { sort: [{ published: 'asc' }, { created_at: 'desc' }] }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # First should be unpublished (Beta Post)
      # Then published sorted by created_at desc (Alpha, Charlie)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles[0]).to eq('Beta Post')
      expect(titles[1]).to eq('Charlie Post')
      expect(titles[2]).to eq('Alpha Post')
    end

    it 'defaults to id ascending when no sort specified' do
      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      ids = json['posts'].map { |p| p['id'] }
      expect(ids).to eq(ids.sort)
    end

    it 'handles invalid sort field gracefully' do
      get '/api/v1/posts', params: { sort: { invalid_field: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_present
    end

    it 'combines sorting with filtering' do
      get '/api/v1/posts',
          params: {
            filter: { published: { eq: true } },
            sort: { title: 'desc' },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Charlie Post', 'Alpha Post'])
    end
  end
end
