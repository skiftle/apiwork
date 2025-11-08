# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Resource override and selective serialization', type: :request do
  before(:each) do
    # Delete comments first due to foreign key constraint
    Comment.delete_all
    Post.delete_all
  end

  describe 'GET /api/v1/articles' do
    it 'serializes with custom resource root key' do
      Post.create!(title: 'Test Post', body: 'Test body', published: true)

      get '/api/v1/articles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json).to have_key('articles')
      expect(json).not_to have_key('posts')
    end

    it 'exposes only attributes defined in resource class' do
      Post.create!(title: 'Test Post', body: 'Test body', published: true)

      get '/api/v1/articles'

      json = JSON.parse(response.body)
      article = json['articles'].first
      expect(article).to have_key('id')
      expect(article).to have_key('title')
      expect(article['title']).to eq('Test Post')
    end

    it 'hides attributes not specified in resource' do
      Post.create!(title: 'Test Post', body: 'Secret body', published: true)

      get '/api/v1/articles'

      json = JSON.parse(response.body)
      article = json['articles'].first
      expect(article).not_to have_key('body')
      expect(article).not_to have_key('published')
    end
  end

  describe 'GET /api/v1/articles/:id' do
    it 'uses custom resource for single resource serialization' do
      post = Post.create!(title: 'Test Post', body: 'Test body', published: true)

      get "/api/v1/articles/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json).to have_key('article')
      expect(json['article']['id']).to eq(post.id)
      expect(json['article']['title']).to eq('Test Post')
      expect(json['article']).not_to have_key('body')
      expect(json['article']).not_to have_key('published')
    end
  end

  describe 'POST /api/v1/articles' do
    it 'accepts minimal input contract and creates full model' do
      article_params = {
        article: {
          title: 'New Article'
        }
      }

      expect {
        post '/api/v1/articles', params: article_params, as: :json
      }.to change(Post, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['article']['title']).to eq('New Article')
      expect(json['article']).not_to have_key('body')

      # Verify full model was created in database
      created_post = Post.last
      expect(created_post.title).to eq('New Article')
      expect(created_post.body).to eq('Auto-generated body')
      expect(created_post.published).to eq(false)
    end

    it 'serializes response through custom resource despite full model' do
      article_params = {
        article: {
          title: 'Article Title'
        }
      }

      post '/api/v1/articles', params: article_params, as: :json

      json = JSON.parse(response.body)
      expect(json['article'].keys.sort).to eq(['id', 'title'])
    end
  end

  describe 'PATCH /api/v1/articles/:id' do
    it 'accepts minimal contract for updates' do
      post_record = Post.create!(title: 'Original', body: 'Original body', published: true)

      patch "/api/v1/articles/#{post_record.id}",
            params: { article: { title: 'Updated Title' } },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['article']['title']).to eq('Updated Title')
      expect(json['article']).not_to have_key('body')

      post_record.reload
      expect(post_record.title).to eq('Updated Title')
    end
  end

  describe 'Resource comparison' do
    it 'same model data serializes differently through different resources' do
      post = Post.create!(title: 'Same Post', body: 'Same body', published: true)

      # Fetch through PostsController (full resource)
      get "/api/v1/posts/#{post.id}"
      post_json = JSON.parse(response.body)

      # Fetch through ArticlesController (minimal resource)
      get "/api/v1/articles/#{post.id}"
      article_json = JSON.parse(response.body)

      # Same underlying model
      expect(post_json['post']['id']).to eq(article_json['article']['id'])
      expect(post_json['post']['title']).to eq(article_json['article']['title'])

      # Different serialization
      expect(post_json['post']).to have_key('body')
      expect(post_json['post']).to have_key('published')
      expect(article_json['article']).not_to have_key('body')
      expect(article_json['article']).not_to have_key('published')

      # Different attribute counts
      expect(post_json['post'].keys.length).to eq(6) # id, title, body, published, created_at, updated_at
      expect(article_json['article'].keys.length).to eq(2) # id, title only
    end
  end

  describe 'DELETE /api/v1/articles/:id' do
    it 'works with custom resource serialization' do
      post_record = Post.create!(title: 'To Delete', body: 'Delete me')

      expect {
        delete "/api/v1/articles/#{post_record.id}"
      }.to change(Post, :count).by(-1)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
    end
  end
end
