# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root key override with root DSL', type: :request do
  describe 'Auto-pluralization with root :article' do
    it 'uses custom singular root key for single resources' do
      post = Post.create!(body: 'Body', published: true, title: 'Draft Article')

      get "/api/v1/articles/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('article')
      expect(json).not_to have_key('post')
      expect(json['article']['title']).to eq('Draft Article')
    end

    it 'uses custom plural root key for collections' do
      Post.create!(body: 'Body 1', published: true, title: 'Article 1')
      Post.create!(body: 'Body 2', published: false, title: 'Article 2')

      get '/api/v1/articles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('articles')
      expect(json).not_to have_key('posts')
      expect(json['articles'].length).to eq(2)
    end

    it 'uses custom root key for input validation' do
      article_params = {
        article: {
          title: 'New Article',
        },
      }

      post '/api/v1/articles', as: :json, params: article_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['article']['title']).to eq('New Article')
    end
  end

  describe 'Explicit plural with root :person, :people' do
    it 'uses custom singular root key (person)' do
      post_record = Post.create!(body: 'Bio', published: true, title: 'John Doe')

      get "/api/v1/persons/#{post_record.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('person')
      expect(json).not_to have_key('post')
      expect(json).not_to have_key('persons') # Not 'persons'
      expect(json['person']['title']).to eq('John Doe')
    end

    it 'uses custom irregular plural root key (people)' do
      Post.create!(body: 'Bio 1', published: true, title: 'Person 1')
      Post.create!(body: 'Bio 2', published: false, title: 'Person 2')

      get '/api/v1/persons'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('people') # Not 'persons'!
      expect(json).not_to have_key('posts')
      expect(json).not_to have_key('persons')
      expect(json['people'].length).to eq(2)
    end

    it 'uses singular root key for input validation' do
      person_params = {
        person: {
          body: 'Bio text',
          published: true,
          title: 'Jane Doe',
        },
      }

      post '/api/v1/persons', as: :json, params: person_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['person']['title']).to eq('Jane Doe')
    end
  end

  describe 'Root key consistency' do
    it 'same model produces different root keys through different resources' do
      post = Post.create!(body: 'Body', published: true, title: 'Same Data')

      # Through PostsController (default: 'post'/'posts')
      get "/api/v1/posts/#{post.id}"
      post_json = JSON.parse(response.body)

      # Through ArticlesController (custom: 'article'/'articles')
      get "/api/v1/articles/#{post.id}"
      article_json = JSON.parse(response.body)

      # Through PersonsController (custom: 'person'/'people')
      get "/api/v1/persons/#{post.id}"
      person_json = JSON.parse(response.body)

      # All return same data but with different root keys
      expect(post_json).to have_key('post')
      expect(article_json).to have_key('article')
      expect(person_json).to have_key('person')

      # Same underlying data
      expect(post_json['post']['id']).to eq(post.id)
      expect(article_json['article']['id']).to eq(post.id)
      expect(person_json['person']['id']).to eq(post.id)
    end
  end
end
