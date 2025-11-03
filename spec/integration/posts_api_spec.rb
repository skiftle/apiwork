# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Posts API', type: :request do
  before(:each) do
    # Clean database before each test to avoid pollution from other test suites
    Post.delete_all
    Comment.delete_all
  end

  describe 'GET /api/v1/posts' do
    it 'returns empty array when no posts exist' do
      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts']).to eq([])
    end

    it 'returns all posts' do
      post1 = Post.create!(title: 'First Post', body: 'First body', published: true)
      post2 = Post.create!(title: 'Second Post', body: 'Second body', published: false)

      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array([post1.title, post2.title])
    end
  end

  describe 'GET /api/v1/posts/:id' do
    it 'returns a single post' do
      post = Post.create!(title: 'Test Post', body: 'Test body', published: true)

      get "/api/v1/posts/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['post']['id']).to eq(post.id)
      expect(json['post']['title']).to eq('Test Post')
      expect(json['post']['body']).to eq('Test body')
      expect(json['post']['published']).to eq(true)
    end

    it 'returns 404 for non-existent post' do
      get '/api/v1/posts/99999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/posts' do
    it 'creates a new post with valid data' do
      post_params = {
        title: 'New Post',
        body: 'New body',
        published: true
      }

      expect {
        post '/api/v1/posts', params: post_params, as: :json
      }.to change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['post']['title']).to eq('New Post')
      expect(json['post']['body']).to eq('New body')
      expect(json['post']['published']).to eq(true)
    end

    it 'rejects post without title' do
      post_params = {
        body: 'Body without title',
        published: false
      }

      expect {
        post '/api/v1/posts', params: post_params, as: :json
      }.not_to change(Post, :count)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(false)
      expect(json['errors']).to be_present
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    it 'updates an existing post' do
      post_record = Post.create!(title: 'Original Title', body: 'Original body', published: false)

      patch "/api/v1/posts/#{post_record.id}",
            params: { title: 'Updated Title', published: true },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['post']['title']).to eq('Updated Title')
      expect(json['post']['published']).to eq(true)

      post_record.reload
      expect(post_record.title).to eq('Updated Title')
      expect(post_record.published).to eq(true)
    end

    it 'returns 404 for non-existent post' do
      patch '/api/v1/posts/99999', params: { title: 'Updated' }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    it 'deletes an existing post' do
      post_record = Post.create!(title: 'To Delete', body: 'Delete me')

      expect {
        delete "/api/v1/posts/#{post_record.id}"
      }.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
    end

    it 'returns 404 for non-existent post' do
      delete '/api/v1/posts/99999'

      expect(response).to have_http_status(:not_found)
    end
  end
end
