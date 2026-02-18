# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Singular resource', type: :request do
  describe 'GET /api/v1/profile' do
    let!(:profile1) do
      Profile.create!(
        bio: 'Billing administrator',
        email: 'admin@billing.test',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )
    end

    it 'returns the profile without :id' do
      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['profile']['name']).to eq('Admin')
      expect(json['profile']['bio']).to eq('Billing administrator')
      expect(json['profile']['timezone']).to eq('Europe/Stockholm')
    end
  end

  describe 'POST /api/v1/profile' do
    it 'creates the profile without :id' do
      post '/api/v1/profile',
           as: :json,
           params: {
             profile: {
               bio: 'Billing administrator',
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
    let!(:profile1) do
      Profile.create!(
        bio: 'Billing administrator',
        email: 'admin@billing.test',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )
    end

    it 'updates the profile without :id' do
      patch '/api/v1/profile',
            as: :json,
            params: { profile: { bio: 'Updated bio' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['profile']['bio']).to eq('Updated bio')
    end
  end

  describe 'DELETE /api/v1/profile' do
    let!(:profile1) do
      Profile.create!(
        bio: 'Billing administrator',
        email: 'admin@billing.test',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )
    end

    it 'deletes the profile without :id' do
      delete '/api/v1/profile'

      expect(response).to have_http_status(:no_content)
      expect(Profile.count).to eq(0)
    end
  end
end
