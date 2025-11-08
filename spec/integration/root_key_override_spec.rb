# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root key override with root DSL', type: :request do
  before(:each) do
    # Delete comments first due to foreign key constraint
    Comment.delete_all
    Post.delete_all
  end

  describe 'Auto-pluralization with root :article' do
    it 'uses custom singular root key for single resources' do
      post = Post.create!(title: 'Test Article', body: 'Body', published: true)

      get "/api/v1/articles/#{post.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('article')
      expect(json).not_to have_key('post')
      expect(json['article']['title']).to eq('Test Article')
    end

    it 'uses custom plural root key for collections' do
      Post.create!(title: 'Article 1', body: 'Body 1', published: true)
      Post.create!(title: 'Article 2', body: 'Body 2', published: false)

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
          title: 'New Article'
        }
      }

      post '/api/v1/articles', params: article_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['article']['title']).to eq('New Article')
    end
  end

  describe 'Explicit plural with root :person, :people' do
    it 'uses custom singular root key (person)' do
      post_record = Post.create!(title: 'John Doe', body: 'Bio', published: true)

      get "/api/v1/persons/#{post_record.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('person')
      expect(json).not_to have_key('post')
      expect(json).not_to have_key('persons')  # Not 'persons'
      expect(json['person']['title']).to eq('John Doe')
    end

    it 'uses custom irregular plural root key (people)' do
      Post.create!(title: 'Person 1', body: 'Bio 1', published: true)
      Post.create!(title: 'Person 2', body: 'Bio 2', published: false)

      get '/api/v1/persons'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('people')  # Not 'persons'!
      expect(json).not_to have_key('posts')
      expect(json).not_to have_key('persons')
      expect(json['people'].length).to eq(2)
    end

    it 'uses singular root key for input validation' do
      person_params = {
        person: {
          title: 'Jane Doe',
          body: 'Bio text',
          published: true
        }
      }

      post '/api/v1/persons', params: person_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['person']['title']).to eq('Jane Doe')
    end
  end

  describe 'Root key consistency' do
    it 'same model produces different root keys through different resources' do
      post = Post.create!(title: 'Same Data', body: 'Body', published: true)

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
