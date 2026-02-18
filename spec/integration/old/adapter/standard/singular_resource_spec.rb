# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Singular resource', type: :request do
  describe 'GET /api/v1/profile' do
    it 'returns the profile without :id in URL' do
      Profile.create!(bio: 'Developer', email: 'admin@billing.test', name: 'Admin', timezone: 'UTC')

      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['profile']['name']).to eq('Admin')
      expect(json['profile']['bio']).to eq('Developer')
      expect(json['profile']['timezone']).to eq('UTC')
    end

    it 'returns 404 when profile does not exist' do
      get '/api/v1/profile'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/profile' do
    it 'creates a profile without :id in URL' do
      post '/api/v1/profile',
           as: :json,
           params: {
             profile: {
               bio: 'New bio',
               email: 'admin@billing.test',
               name: 'Admin',
               timezone: 'Europe/Stockholm',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['profile']['name']).to eq('Admin')
      expect(json['profile']['timezone']).to eq('Europe/Stockholm')
    end
  end

  describe 'PATCH /api/v1/profile' do
    it 'updates the profile without :id in URL' do
      Profile.create!(bio: 'Original bio', name: 'Admin', timezone: 'UTC')

      patch '/api/v1/profile',
            as: :json,
            params: { profile: { bio: 'Updated bio' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['profile']['bio']).to eq('Updated bio')
    end
  end

  describe 'DELETE /api/v1/profile' do
    it 'deletes the profile without :id in URL' do
      Profile.create!(bio: 'To delete', name: 'Admin', timezone: 'UTC')

      delete '/api/v1/profile'

      expect(response).to have_http_status(:no_content)
      expect(Profile.count).to eq(0)
    end
  end

  describe 'Singular resource serialization' do
    it 'serializes all attributes' do
      profile = Profile.create!(
        bio: 'Developer',
        email: 'admin@billing.test',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )

      get '/api/v1/profile'

      json = JSON.parse(response.body)
      expect(json['profile']['id']).to eq(profile.id)
      expect(json['profile']['bio']).to eq('Developer')
      expect(json['profile']['email']).to eq('admin@billing.test')
      expect(json['profile']['name']).to eq('Admin')
      expect(json['profile']['timezone']).to eq('Europe/Stockholm')
    end
  end
end
