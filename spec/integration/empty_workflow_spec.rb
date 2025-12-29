# frozen_string_literal: true

require 'rails_helper'

# empty attribute option provides bidirectional transformation:
# - Serialize (output): nil → "" (frontend always gets string, never null)
# - Deserialize (input): "" → nil (database stores nil for empty strings)
#
# This allows frontend to work with strings (no nullable types needed),
# while backend normalizes empty values to nil in the database.

RSpec.describe 'empty workflow', type: :request do
  describe 'POST /api/v1/users' do
    context 'when name is empty string' do
      it 'converts empty string to nil in database' do
        post '/api/v1/users',
             as: :json,
             params: {
               user: {
                 email: 'test@example.com',
                 name: '',
               },
             }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        # Empty string converted to nil in database (blank_to_nil deserialization)
        user = User.last
        expect(user.name).to be_nil

        # Response serializes nil back to empty string (nil_to_empty serialization)
        expect(json.dig('user', 'name')).to eq('')
      end
    end

    context 'when name is null' do
      it 'rejects null values' do
        post '/api/v1/users',
             as: :json,
             params: {
               user: {
                 email: 'test@example.com',
                 name: nil,
               },
             }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues'].first['code']).to eq('value_null')
      end
    end

    context 'when name has value' do
      it 'stores and returns the value unchanged' do
        post '/api/v1/users',
             as: :json,
             params: {
               user: {
                 email: 'test@example.com',
                 name: 'John Doe',
               },
             }

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
      it 'converts empty string to nil in database' do
        patch "/api/v1/users/#{user.id}",
              as: :json,
              params: {
                user: {
                  name: '',
                },
              }

        expect(response).to have_http_status(:ok)

        # Empty string converted to nil in database
        user.reload
        expect(user.name).to be_nil
      end
    end

    context 'when updating name to null' do
      it 'rejects null values' do
        patch "/api/v1/users/#{user.id}",
              as: :json,
              params: {
                user: {
                  name: nil,
                },
              }

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

  describe 'round-trip behavior' do
    it 'maintains "" → nil → "" cycle correctly' do
      # 1. POST with empty string
      post '/api/v1/users',
           as: :json,
           params: {
             user: {
               email: 'test@example.com',
               name: '',
             },
           }

      user_id = JSON.parse(response.body).dig('user', 'id')

      # 2. Database has nil (empty string was converted)
      user = User.find(user_id)
      expect(user.name).to be_nil

      # 3. GET returns empty string (nil converted back)
      get "/api/v1/users/#{user_id}", as: :json
      json = JSON.parse(response.body)
      expect(json.dig('user', 'name')).to eq('')

      # 4. PATCH with empty string again
      patch "/api/v1/users/#{user_id}",
            as: :json,
            params: {
              user: {
                name: '',
              },
            }

      # 5. Database still has nil
      user.reload
      expect(user.name).to be_nil

      # 6. GET still returns empty string
      get "/api/v1/users/#{user_id}", as: :json
      json = JSON.parse(response.body)
      expect(json.dig('user', 'name')).to eq('')
    end

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
    context 'when empty only applies to name attribute' do
      let!(:user) { User.create!(email: nil, name: nil) }

      it 'transforms name but not email' do
        get "/api/v1/users/#{user.id}", as: :json

        json = JSON.parse(response.body)

        # name has empty → returns ""
        expect(json.dig('user', 'name')).to eq('')

        # email does NOT have empty → returns nil
        expect(json.dig('user', 'email')).to be_nil
      end
    end
  end
end
