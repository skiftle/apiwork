# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Encode and Decode attribute options', type: :request do
  describe 'decode: on attribute' do
    it 'transforms input value before storing in database' do
      user_params = {
        user: {
          email: 'john.doe@example.com',
          name: 'John Doe',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:created)

      created_user = User.last
      # deserialize transforms 'john.doe@example.com' to 'JOHN.DOE@EXAMPLE.COM' before storing
      expect(created_user.email).to eq('JOHN.DOE@EXAMPLE.COM')
    end

    it 'applies decoding on update operations' do
      user_record = User.create!(email: 'ORIGINAL@EXAMPLE.COM', name: 'Jane')

      patch_params = {
        user: {
          email: 'updated@example.com',
        },
      }

      patch "/api/v1/users/#{user_record.id}", as: :json, params: patch_params

      expect(response).to have_http_status(:ok)

      user_record.reload
      # deserialize transforms 'updated@example.com' to 'UPDATED@EXAMPLE.COM'
      expect(user_record.email).to eq('UPDATED@EXAMPLE.COM')
    end

    it 'handles nil values in decoding' do
      user_params = {
        user: {
          email: nil,
          name: 'John',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      # email is nullable, so nil is accepted
      expect(response).to have_http_status(:created)

      created_user = User.last
      expect(created_user.email).to be_nil
    end
  end

  describe 'encode: on attribute' do
    it 'transforms output value when reading from database' do
      User.create!(email: 'STORED@UPPERCASE.COM', name: 'John')

      get '/api/v1/users'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # serialize transforms 'STORED@UPPERCASE.COM' to 'stored@uppercase.com' in output
      expect(json['users'].first['email']).to eq('stored@uppercase.com')
    end

    it 'applies encoding on show endpoint' do
      user_record = User.create!(email: 'DATABASE@VALUE.COM', name: 'Jane')

      get "/api/v1/users/#{user_record.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # serialize transforms 'DATABASE@VALUE.COM' to 'database@value.com' in output
      expect(json['user']['email']).to eq('database@value.com')
    end
  end

  describe 'serialize and deserialize together' do
    it 'applies both transformations in full lifecycle' do
      # Step 1: Create with deserialize (input -> DB)
      user_params = {
        user: {
          email: 'lowercase@input.com',
          name: 'Test User',
        },
      }

      post '/api/v1/users', as: :json, params: user_params
      expect(response).to have_http_status(:created)

      created_user = User.last
      # Stored in uppercase due to deserialize
      expect(created_user.email).to eq('LOWERCASE@INPUT.COM')

      # Step 2: Read with serialize (DB -> output)
      get "/api/v1/users/#{created_user.id}"
      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      # Output in lowercase due to serialize
      expect(json['user']['email']).to eq('lowercase@input.com')
    end

    it 'round-trips correctly through create and update' do
      # Create
      user_params = { user: { email: 'original@test.com', name: 'User' } }
      post '/api/v1/users', as: :json, params: user_params

      user_id = JSON.parse(response.body)['user']['id']

      # Verify stored in uppercase
      expect(User.find(user_id).email).to eq('ORIGINAL@TEST.COM')

      # Update
      patch_params = { user: { email: 'updated@test.com' } }
      patch "/api/v1/users/#{user_id}", as: :json, params: patch_params
      expect(response).to have_http_status(:ok)

      # Verify updated in uppercase
      expect(User.find(user_id).email).to eq('UPDATED@TEST.COM')

      # Read
      get "/api/v1/users/#{user_id}"
      json = JSON.parse(response.body)

      # Verify output in lowercase
      expect(json['user']['email']).to eq('updated@test.com')
    end
  end
end
