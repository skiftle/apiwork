# frozen_string_literal: true

require 'rails_helper'

# NOTE: null_to_empty currently only works for OUTPUT serialization, not INPUT deserialization
# - Serialize (output): nil → "" (works ✅)
# - Deserialize (input): "" → nil (NOT IMPLEMENTED ❌)
#
# The blank_to_nil deserialize transformer is defined but never called during input parsing.
# This test documents the CURRENT behavior, not the ideal behavior.

RSpec.describe 'null_to_empty workflow', type: :request do
  describe 'POST /api/v1/users' do
    context 'when name is empty string' do
      it 'stores empty string as-is (deserialization not implemented)' do
        post '/api/v1/users', params: {
          user: {
            email: 'test@example.com',
            name: ''
          }
        }, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        # Database stores empty string (deserialization transformers not applied)
        user = User.last
        expect(user.name).to eq('')

        # Response also returns empty string
        expect(json.dig('user', 'name')).to eq('')
      end
    end

    context 'when name is null' do
      it 'rejects null values' do
        post '/api/v1/users', params: {
          user: {
            email: 'test@example.com',
            name: nil
          }
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues'].first['code']).to eq('value_null')
      end
    end

    context 'when name has value' do
      it 'stores and returns the value unchanged' do
        post '/api/v1/users', params: {
          user: {
            email: 'test@example.com',
            name: 'John Doe'
          }
        }, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        # Value preserved
        expect(json.dig('user', 'name')).to eq('John Doe')

        user = User.last
        expect(user.name).to eq('John Doe')
      end
    end
  end

  describe 'PATCH /api/v1/users/:id' do
    let!(:user) { User.create!(email: 'test@example.com', name: 'Original Name') }

    context 'when updating name to empty string' do
      it 'stores empty string as-is' do
        patch "/api/v1/users/#{user.id}", params: {
          user: {
            name: ''
          }
        }, as: :json

        expect(response).to have_http_status(:ok)

        # Database stores empty string
        user.reload
        expect(user.name).to eq('')
      end
    end

    context 'when updating name to null' do
      it 'rejects null values' do
        patch "/api/v1/users/#{user.id}", params: {
          user: {
            name: nil
          }
        }, as: :json

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues'].first['code']).to eq('value_null')
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    context 'when name is nil in database' do
      let!(:user) { User.create!(email: 'test@example.com', name: nil) }

      it 'serializes nil as empty string' do
        get "/api/v1/users/#{user.id}", as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        # nil → "" in output (WORKS ✅)
        expect(json.dig('user', 'name')).to eq('')
      end
    end

    context 'when name has value in database' do
      let!(:user) { User.create!(email: 'test@example.com', name: 'John Doe') }

      it 'returns the value unchanged' do
        get "/api/v1/users/#{user.id}", as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json.dig('user', 'name')).to eq('John Doe')
      end
    end
  end

  describe 'null_to_empty serialization (the part that works)' do
    it 'converts nil to empty string on output' do
      # Create user directly with nil (bypassing API)
      user = User.create!(email: 'test@example.com', name: nil)

      # GET returns empty string
      get "/api/v1/users/#{user.id}", as: :json
      json = JSON.parse(response.body)

      expect(json.dig('user', 'name')).to eq('')
    end
  end

  describe 'attribute specificity' do
    context 'when null_to_empty only applies to name attribute' do
      let!(:user) { User.create!(email: nil, name: nil) }

      it 'transforms name but not email' do
        get "/api/v1/users/#{user.id}", as: :json

        json = JSON.parse(response.body)

        # name has null_to_empty → returns ""
        expect(json.dig('user', 'name')).to eq('')

        # email does NOT have null_to_empty → returns nil
        expect(json.dig('user', 'email')).to be_nil
      end
    end
  end
end
