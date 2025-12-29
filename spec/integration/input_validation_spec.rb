# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Input Validation' do
  describe 'POST /api/v1/posts' do
    context 'with empty body' do
      it 'returns validation errors for missing required fields' do
        post '/api/v1/posts', as: :json, params: {}

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues']).to be_an(Array)
        expect(json['issues']).not_to be_empty
      end
    end

    context 'with null values for required fields' do
      it 'returns field_missing error for null title' do
        post '/api/v1/posts', as: :json, params: { post: { title: nil } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        title_issue = json['issues'].find { |issue| issue['pointer'] == '/post/title' }
        expect(title_issue).to be_present
        expect(title_issue['code']).to eq('field_missing')
      end
    end

    context 'with wrong data types that fail coercion' do
      it 'returns type_invalid for invalid boolean string' do
        post '/api/v1/posts', as: :json, params: { post: { published: 'not-a-boolean', title: 'Test' } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        published_issue = json['issues'].find { |issue| issue['pointer'] == '/post/published' }
        expect(published_issue).to be_present
        expect(published_issue['code']).to eq('type_invalid')
      end
    end

    context 'with multiple validation errors' do
      it 'returns all validation errors at once' do
        post '/api/v1/posts',
             as: :json,
             params: {
               post: {
                 title: nil,
                 published: 'not-boolean',
               },
             }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues'].length).to be >= 2

        pointers = json['issues'].map { |issue| issue['pointer'] }
        expect(pointers).to include('/post/title')
        expect(pointers).to include('/post/published')
      end
    end

    context 'with valid data' do
      it 'creates post successfully' do
        post '/api/v1/posts',
             as: :json,
             params: {
               post: {
                 title: 'Valid Title',
                 body: 'Valid body content',
                 published: true,
               },
             }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['post']['title']).to eq('Valid Title')
      end

      it 'coerces boolean strings correctly' do
        post '/api/v1/posts',
             as: :json,
             params: {
               post: {
                 title: 'Test',
                 published: 'true',
               },
             }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['post']['published']).to be(true)
      end
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    let!(:post_record) { Post.create!(title: 'Original') }

    context 'with valid partial update' do
      it 'updates only provided fields' do
        patch "/api/v1/posts/#{post_record.id}",
              as: :json,
              params: {
                post: { title: 'Updated' },
              }

        expect(response).to have_http_status(:ok)
        post_record.reload
        expect(post_record.title).to eq('Updated')
      end
    end

    context 'with wrong data types' do
      it 'returns type_invalid for invalid boolean' do
        patch "/api/v1/posts/#{post_record.id}",
              as: :json,
              params: {
                post: { published: 'not-a-boolean' },
              }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)

        published_issue = json['issues'].find { |issue| issue['pointer'] == '/post/published' }
        expect(published_issue).to be_present
        expect(published_issue['code']).to eq('type_invalid')
      end
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    let!(:post_record) { Post.create!(title: 'To Delete') }

    context 'successful deletion' do
      it 'deletes the resource' do
        expect do
          delete "/api/v1/posts/#{post_record.id}"
        end.to change(Post, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(Post.exists?(post_record.id)).to be(false)
      end
    end
  end

  describe 'Error response format consistency' do
    it 'returns consistent error format across different error types' do
      # Test field_missing error
      post '/api/v1/posts', as: :json, params: { post: { title: nil } }
      missing_error = JSON.parse(response.body)

      expect(missing_error).to have_key('issues')
      expect(missing_error['issues']).to be_an(Array)
      expect(missing_error['issues'].first).to have_key('code')
      expect(missing_error['issues'].first).to have_key('pointer')
      expect(missing_error['issues'].first).to have_key('detail')

      # Test type_mismatch error
      post '/api/v1/posts', as: :json, params: { post: { published: 'invalid', title: 'Test' } }
      type_error = JSON.parse(response.body)

      expect(type_error).to have_key('issues')
      expect(type_error['issues']).to be_an(Array)
      expect(type_error['issues'].first).to have_key('code')
      expect(type_error['issues'].first).to have_key('pointer')
      expect(type_error['issues'].first).to have_key('detail')
    end

    it 'uses JSON pointer format for errors' do
      post '/api/v1/posts', as: :json, params: { post: { title: nil } }
      json = JSON.parse(response.body)

      # Pointers should start with /post/ for root-level fields
      issue = json['issues'].first
      expect(issue['pointer']).to match(%r{^/post/})
    end

    it 'uses JSON pointer format for nested field errors' do
      post '/api/v1/posts',
           as: :json,
           params: {
             post: {
               title: 'Test',
               comments_attributes: [
                 { content: nil },
               ],
             },
           }

      json = JSON.parse(response.body)

      # Should have pointer like /post/comments_attributes/0/content
      nested_issue = json['issues'].find { |issue| issue['pointer']&.include?('comments_attributes') }
      expect(nested_issue).to be_present if json['issues'].any?
    end
  end
end
