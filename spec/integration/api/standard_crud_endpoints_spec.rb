# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Standard CRUD endpoints', type: :request do
  describe 'GET /api/v1/posts' do
    it 'wraps empty collections in response envelope' do
      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts']).to eq([])
    end

    it 'serializes collections through resource class' do
      post1 = Post.create!(body: 'First body', published: true, title: 'First Post')
      post2 = Post.create!(body: 'Second body', published: false, title: 'Second Post')

      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly(post1.title, post2.title)
    end
  end

  describe 'GET /api/v1/posts/:id' do
    it 'serializes single resource with all attributes' do
      post = Post.create!(body: 'Draft body', published: true, title: 'Draft Post')

      get "/api/v1/posts/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['id']).to eq(post.id)
      expect(json['post']['title']).to eq('Draft Post')
      expect(json['post']['body']).to eq('Draft body')
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
          body: 'New body',
          published: true,
          title: 'New Post',
        },
      }

      expect do
        post '/api/v1/posts', as: :json, params: post_params
      end.to change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['post']['title']).to eq('New Post')
      expect(json['post']['body']).to eq('New body')
      expect(json['post']['published']).to be(true)
    end

    it 'returns validation errors for required fields' do
      post_params = {
        post: {
          body: 'Body without title',
          published: false,
        },
      }

      expect do
        post '/api/v1/posts', as: :json, params: post_params
      end.not_to change(Post, :count)

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_present
    end
  end

  describe 'JSON column support' do
    it 'accepts JSON data for :json columns on create' do
      post_params = {
        post: {
          body: 'Body text',
          metadata: {
            author_notes: 'Draft version',
            tags: %w[ruby rails],
            version: 1,
          },
          published: false,
          title: 'Post with Metadata',
        },
      }

      expect do
        post '/api/v1/posts', as: :json, params: post_params
      end.to change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      # Keys inside JSON objects remain as-is with output_key_format :keep
      expect(json['post']['metadata']).to eq(
        {
          'author_notes' => 'Draft version',
          'tags' => %w[ruby rails],
          'version' => 1,
        },
      )

      # Verify database storage (keys stored as-is in database)
      created_post = Post.last
      expect(created_post.metadata).to eq(
        {
          'author_notes' => 'Draft version',
          'tags' => %w[ruby rails],
          'version' => 1,
        },
      )
    end

    it 'returns JSON data when reading records with :json columns' do
      post_record = Post.create!(
        body: 'Body',
        metadata: {
          'tags' => %w[api test],
          'priority' => 'high',
        },
        title: 'Post with Metadata',
      )

      get "/api/v1/posts/#{post_record.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['metadata']).to eq(
        {
          'priority' => 'high',
          'tags' => %w[api test],
        },
      )
    end

    it 'updates JSON columns with partial data' do
      post_record = Post.create!(
        body: 'Body',
        metadata: { 'version' => 1 },
        published: false,
        title: 'Original',
      )

      patch "/api/v1/posts/#{post_record.id}",
            as: :json,
            params: {
              post: {
                body: 'Body',
                metadata: { 'version' => 2, 'updated' => true },
                published: false,
                title: 'Original',
              },
            }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['metadata']).to eq(
        {
          'updated' => true,
          'version' => 2,
        },
      )
    end

    it 'accepts null for optional JSON columns' do
      post_params = {
        post: {
          body: 'Body',
          metadata: nil,
          title: 'Post without Metadata',
        },
      }

      post '/api/v1/posts', as: :json, params: post_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['post']['metadata']).to be_nil
    end

    it 'handles empty object for JSON columns' do
      post_params = {
        post: {
          body: 'Body',
          metadata: {},
          title: 'Post with Empty Metadata',
        },
      }

      post '/api/v1/posts', as: :json, params: post_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['post']['metadata']).to eq({})
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    it 'handles partial updates through contract' do
      post_record = Post.create!(body: 'Original body', published: false, title: 'Original Title')

      patch "/api/v1/posts/#{post_record.id}",
            as: :json,
            params: { post: { published: true, title: 'Updated Title' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['title']).to eq('Updated Title')
      expect(json['post']['published']).to be(true)

      post_record.reload
      expect(post_record.title).to eq('Updated Title')
      expect(post_record.published).to be(true)
    end

    it 'returns 404 when updating missing resource' do
      patch '/api/v1/posts/99999', as: :json, params: { post: { title: 'Updated' } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    it 'deletes the resource' do
      post_record = Post.create!(body: 'Delete me', title: 'To Delete')

      expect do
        delete "/api/v1/posts/#{post_record.id}"
      end.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:ok)
      expect(Post.exists?(post_record.id)).to be(false)
    end

    it 'returns 404 when deleting missing resource' do
      delete '/api/v1/posts/99999'

      expect(response).to have_http_status(:not_found)
    end
  end
end
