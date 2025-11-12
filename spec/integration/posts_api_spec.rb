# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Standard CRUD endpoints', type: :request do
  describe 'GET /api/v1/posts' do
    it 'wraps empty collections in response envelope' do
      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts']).to eq([])
    end

    it 'serializes collections through resource class' do
      post1 = Post.create!(title: 'First Post', body: 'First body', published: true)
      post2 = Post.create!(title: 'Second Post', body: 'Second body', published: false)

      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly(post1.title, post2.title)
    end
  end

  describe 'GET /api/v1/posts/:id' do
    it 'serializes single resource with all attributes' do
      post = Post.create!(title: 'Test Post', body: 'Test body', published: true)

      get "/api/v1/posts/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['post']['id']).to eq(post.id)
      expect(json['post']['title']).to eq('Test Post')
      expect(json['post']['body']).to eq('Test body')
      expect(json['post']['published']).to be(true)
    end

    it 'returns 404 when resource not found' do
      get '/api/v1/posts/99999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/posts' do
    it 'parses input contract and returns serialized resource' do
      post_params = {
        post: {
          title: 'New Post',
          body: 'New body',
          published: true
        }
      }

      expect do
        post '/api/v1/posts', params: post_params, as: :json
      end.to change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['post']['title']).to eq('New Post')
      expect(json['post']['body']).to eq('New body')
      expect(json['post']['published']).to be(true)
    end

    it 'returns validation errors for required fields' do
      post_params = {
        post: {
          body: 'Body without title',
          published: false
        }
      }

      expect do
        post '/api/v1/posts', params: post_params, as: :json
      end.not_to change(Post, :count)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(false)
      expect(json['errors']).to be_present
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    it 'handles partial updates through contract' do
      post_record = Post.create!(title: 'Original Title', body: 'Original body', published: false)

      patch "/api/v1/posts/#{post_record.id}",
            params: { post: { title: 'Updated Title', published: true } },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['post']['title']).to eq('Updated Title')
      expect(json['post']['published']).to be(true)

      post_record.reload
      expect(post_record.title).to eq('Updated Title')
      expect(post_record.published).to be(true)
    end

    it 'returns 404 when updating missing resource' do
      patch '/api/v1/posts/99999', params: { post: { title: 'Updated' } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    it 'returns success envelope after deletion' do
      post_record = Post.create!(title: 'To Delete', body: 'Delete me')

      expect do
        delete "/api/v1/posts/#{post_record.id}"
      end.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
    end

    it 'returns 404 when deleting missing resource' do
      delete '/api/v1/posts/99999'

      expect(response).to have_http_status(:not_found)
    end
  end
end
