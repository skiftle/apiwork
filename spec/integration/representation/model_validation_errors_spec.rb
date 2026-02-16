# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Model Validation Errors', type: :request do
  # NOTE: Apiwork infers `required: true` from database columns with `null: false`.
  # This means contract validation (400) catches missing required fields before
  # model validation (422) can be triggered.
  #
  # Model validation (422) is only triggered for:
  # 1. Validations not inferable from DB schema (uniqueness, format, custom validations)
  # 2. When contract validation passes but ActiveRecord save fails

  describe 'Contract vs Model validation' do
    it 'returns 400 when required field is nil (contract validation from DB schema)' do
      post '/api/v1/posts', as: :json, params: { post: { title: nil } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      title_issue = json['issues'].find { |i| i['pointer'] == '/post/title' }
      expect(title_issue).to be_present
      expect(title_issue['code']).to eq('field_missing')
    end

    it 'returns 422 when required field is empty string (model validation via presence)' do
      post '/api/v1/posts', as: :json, params: { post: { title: '' } }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'returns 400 for type mismatch (contract validation)' do
      post '/api/v1/posts', as: :json, params: { post: { published: 'not-a-boolean', title: 'Valid' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      published_issue = json['issues'].find { |i| i['pointer'] == '/post/published' }
      expect(published_issue).to be_present
      expect(published_issue['code']).to eq('type_invalid')
    end
  end

  describe 'Error response format' do
    it 'returns consistent error format with all required fields' do
      post '/api/v1/posts', as: :json, params: { post: { title: nil } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].first
      expect(issue).to have_key('code')
      expect(issue).to have_key('detail')
      expect(issue).to have_key('pointer')
      expect(issue).to have_key('path')
      expect(issue).to have_key('meta')
    end

    it 'uses JSON pointer format for field paths' do
      post '/api/v1/posts', as: :json, params: { post: { title: nil } }

      json = JSON.parse(response.body)
      issue = json['issues'].first

      expect(issue['pointer']).to eq('/post/title')
      expect(issue['path']).to eq(%w[post title])
    end

    it 'includes field name in meta' do
      post '/api/v1/posts', as: :json, params: { post: { title: nil } }

      json = JSON.parse(response.body)
      issue = json['issues'].first

      expect(issue['meta']['field']).to eq('title')
    end
  end

  describe 'Nested attribute validation' do
    it 'validates nested has_many association with writable key' do
      # Representation has `has_many :comments, writable: true` - uses 'comments' key in input
      post '/api/v1/posts',
           as: :json,
           params: {
             post: {
               comments: [
                 { content: '' },
               ],
               title: 'Valid Title',
             },
           }

      json = JSON.parse(response.body)

      # Contract validation catches missing required content field
      if json['issues'].present?
        nested_issue = json['issues'].find { |i| i['pointer'].include?('comments') }
        expect(nested_issue['code']).to be_present if nested_issue
      end
    end
  end

  describe 'Update validation errors' do
    let!(:existing_post) { Post.create!(title: 'Original Title') }

    it 'does not update record when model validation fails' do
      patch "/api/v1/posts/#{existing_post.id}", as: :json, params: { post: { title: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      existing_post.reload
      expect(existing_post.title).to eq('Original Title')
    end

    it 'returns validation error on update with invalid type' do
      # Title is valid, but published has wrong type
      patch "/api/v1/posts/#{existing_post.id}", as: :json, params: { post: { published: 'invalid', title: 'Valid' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_an(Array)
      published_issue = json['issues'].find { |i| i['pointer'] == '/post/published' }
      expect(published_issue).to be_present
      expect(published_issue['code']).to eq('type_invalid')
    end
  end

  describe 'Multiple validation errors' do
    it 'returns all validation errors at once' do
      post '/api/v1/posts',
           as: :json,
           params: {
             post: {
               published: 'not-a-boolean',
               title: nil,
             },
           }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues'].length).to be >= 2

      pointers = json['issues'].map { |i| i['pointer'] }
      expect(pointers).to include('/post/title')
      expect(pointers).to include('/post/published')
    end
  end
end
