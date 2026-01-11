# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Unknown query parameter validation', type: :request do
  let!(:post_record) { Post.create!(body: 'Body', title: 'Draft Post') }

  describe 'GET /api/v1/posts/:id (show)' do
    it 'rejects unknown query parameters' do
      get "/api/v1/posts/#{post_record.id}", params: { unknown_param: 'value' }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues'].first['code']).to eq('field_unknown')
    end

    it 'allows valid include parameter' do
      get "/api/v1/posts/#{post_record.id}", params: { include: { comments: true } }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /api/v1/posts/:id (update)' do
    it 'rejects unknown query parameters' do
      patch "/api/v1/posts/#{post_record.id}",
            as: :json,
            params: { post: { title: 'Updated' }, unknown_param: 'value' }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues'].first['code']).to eq('field_unknown')
    end
  end

  describe 'DELETE /api/v1/posts/:id (destroy)' do
    it 'rejects unknown query parameters' do
      # Send params via query string, not body
      delete "/api/v1/posts/#{post_record.id}?unknown_param=value"

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues'].first['code']).to eq('field_unknown')
    end
  end
end
