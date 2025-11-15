# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sorting API', type: :request do
  let!(:post_a) { Post.create!(title: 'Alpha Post', body: 'Content A', published: true, created_at: 3.days.ago) }
  let!(:post_b) { Post.create!(title: 'Beta Post', body: 'Content B', published: false, created_at: 1.day.ago) }
  let!(:post_c) { Post.create!(title: 'Charlie Post', body: 'Content C', published: true, created_at: 2.days.ago) }

  describe 'GET /api/v1/posts with sorting' do
    it 'sorts by title ascending' do
      get '/api/v1/posts', params: { sort: { title: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Alpha Post', 'Beta Post', 'Charlie Post'])
    end

    it 'sorts by title descending' do
      get '/api/v1/posts', params: { sort: { title: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Charlie Post', 'Beta Post', 'Alpha Post'])
    end

    it 'sorts by created_at ascending' do
      get '/api/v1/posts', params: { sort: { created_at: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Alpha Post', 'Charlie Post', 'Beta Post'])
    end

    it 'sorts by created_at descending' do
      get '/api/v1/posts', params: { sort: { created_at: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Beta Post', 'Charlie Post', 'Alpha Post'])
    end

    it 'sorts by boolean field' do
      get '/api/v1/posts', params: { sort: { published: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      published_values = json['posts'].map { |p| p['published'] }
      expect(published_values.first).to be(false)
      expect(published_values.last).to be(true)
    end

    it 'sorts by multiple fields' do
      get '/api/v1/posts', params: { sort: [{ published: 'asc' }, { created_at: 'desc' }] }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)

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
      expect(json['ok']).to be(true)
      ids = json['posts'].map { |p| p['id'] }
      expect(ids).to eq(ids.sort)
    end

    it 'handles invalid sort field gracefully' do
      get '/api/v1/posts', params: { sort: { invalid_field: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(false)
      expect(json['issues']).to be_present
    end

    it 'combines sorting with filtering' do
      get '/api/v1/posts', params: {
        filter: { published: { eq: true } },
        sort: { title: 'desc' }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(['Charlie Post', 'Alpha Post'])
    end
  end
end
