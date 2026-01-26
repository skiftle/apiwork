# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Singular Resource API', type: :request do
  let(:user) { User.create!(email: 'jane@customer.com', name: 'Jane Doe') }

  describe 'Singular resource routing' do
    it 'routes to show without :id parameter' do
      Profile.create!(user:, bio: 'Developer bio', timezone: 'UTC')

      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['profile']['bio']).to eq('Developer bio')
    end

    it 'routes to create without :id parameter' do
      post '/api/v1/profile',
           as: :json,
           params: {
             profile: {
               bio: 'New bio',
               timezone: 'Europe/Stockholm',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['profile']['bio']).to eq('New bio')
    end

    it 'routes to update without :id parameter' do
      Profile.create!(user:, bio: 'Original bio', timezone: 'UTC')

      patch '/api/v1/profile',
            as: :json,
            params: {
              profile: { bio: 'Updated bio' },
            }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['profile']['bio']).to eq('Updated bio')
    end

    it 'routes to destroy without :id parameter' do
      Profile.create!(user:, bio: 'To delete', timezone: 'UTC')

      delete '/api/v1/profile'

      expect(response).to have_http_status(:no_content)
      expect(Profile.count).to eq(0)
    end

    it 'singular resource uses singular path' do
      user = User.create!(email: 'john@customer.com', name: 'John Smith')
      Profile.create!(user:, bio: 'Developer bio', timezone: 'UTC')

      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'Singular resource serialization' do
    it 'serializes all attributes' do
      profile = Profile.create!(
        user:,
        avatar_url: 'https://cdn.billing.com/avatar.png',
        bio: 'Developer',
        timezone: 'Europe/Stockholm',
      )

      get '/api/v1/profile'

      json = JSON.parse(response.body)
      expect(json['profile']['id']).to eq(profile.id)
      expect(json['profile']['bio']).to eq('Developer')
      expect(json['profile']['avatar_url']).to eq('https://cdn.billing.com/avatar.png')
      expect(json['profile']['timezone']).to eq('Europe/Stockholm')
    end

    it 'has belongs_to association configured' do
      associations = Api::V1::ProfileRepresentation.associations
      user_assoc = associations[:user]

      expect(user_assoc).to be_present
      expect(user_assoc.type).to eq(:belongs_to)
    end
  end

  describe 'Singular resource error handling' do
    it 'returns 404 when resource does not exist' do
      get '/api/v1/profile'

      expect(response).to have_http_status(:not_found)
    end
  end
end
