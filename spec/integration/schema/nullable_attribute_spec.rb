# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nullable attribute option', type: :request do
  describe 'nullable: true - allows nil values' do
    it 'accepts nil value on create' do
      user_params = {
        user: {
          email: nil,
          name: 'Test User',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['user']['email']).to be_nil

      user = User.last
      expect(user.email).to be_nil
    end

    it 'omits nil value on update (nil values are omitted from params)' do
      # When sending nil in JSON, Rails/Apiwork omits it from params
      # This is correct REST API behavior - omitted fields are not updated
      user = User.create!(email: 'original@example.com', name: 'Test User')

      patch "/api/v1/users/#{user.id}",
            as: :json,
            params: { user: { email: nil } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # nil in params is omitted, so email remains unchanged
      expect(json['user']['email']).to eq('original@example.com')

      user.reload
      expect(user.email).to eq('original@example.com')
    end

    it 'returns nil in response when value is nil' do
      user = User.create!(email: nil, name: 'Test User')

      get "/api/v1/users/#{user.id}", as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['user']['email']).to be_nil
    end

    it 'allows setting value after nil' do
      user = User.create!(email: nil, name: 'Test User')

      patch "/api/v1/users/#{user.id}",
            as: :json,
            params: { user: { email: 'new@example.com' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # Deserialize transforms to uppercase, serialize transforms back to lowercase for output
      expect(json['user']['email']).to eq('new@example.com')

      user.reload
      expect(user.email).to eq('NEW@EXAMPLE.COM') # Stored uppercased
    end
  end

  describe 'default (not nullable) - rejects nil values' do
    it 'rejects nil value on create' do
      user_params = {
        user: {
          email: 'test@example.com',
          name: nil,
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_present
      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue).to be_present
      expect(issue['code']).to eq('value_null')
    end

    it 'rejects nil value on update' do
      user = User.create!(email: 'test@example.com', name: 'Original Name')

      patch "/api/v1/users/#{user.id}",
            as: :json,
            params: { user: { name: nil } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('value_null')

      user.reload
      expect(user.name).to eq('Original Name') # Unchanged
    end
  end

  describe 'empty: true combined with nullable: false' do
    it 'allows empty string but rejects nil' do
      # name has empty: true but NOT nullable: true
      # empty string → allowed (converts to nil)
      # nil → rejected (value_null)

      post '/api/v1/users',
           as: :json,
           params: { user: { email: 'test@example.com', name: '' } }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['user']['name']).to eq('') # empty string allowed

      user = User.last
      expect(user.name).to be_nil # Converted to nil in DB

      # But explicit nil is rejected
      post '/api/v1/users',
           as: :json,
           params: { user: { email: 'test2@example.com', name: nil } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('value_null')
    end
  end

  describe 'nullable: true allows serialize/deserialize transformations' do
    it 'transforms nil values through serialize/deserialize' do
      # email has nullable: true + serialize/deserialize
      user = User.create!(email: nil, name: 'Test')

      # Serialize should handle nil gracefully (value&.downcase)
      get "/api/v1/users/#{user.id}", as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['user']['email']).to be_nil # Safe navigation handles nil

      # Update with value
      patch "/api/v1/users/#{user.id}",
            as: :json,
            params: { user: { email: 'NEW@EXAMPLE.COM' } }

      user.reload
      expect(user.email).to eq('NEW@EXAMPLE.COM') # Deserialize uppercases

      # Get returns lowercased
      get "/api/v1/users/#{user.id}", as: :json
      json = JSON.parse(response.body)
      expect(json['user']['email']).to eq('new@example.com') # Serialize downcases
    end
  end
end
