# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Singular resource', type: :request do
  describe 'GET /api/v1/profile' do
    it 'returns the profile without :id' do
      Profile.create!(
        bio: 'Billing administrator',
        email: 'admin@billing.test',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )

      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['profile']['name']).to eq('Admin')
      expect(body['profile']['bio']).to eq('Billing administrator')
      expect(body['profile']['timezone']).to eq('Europe/Stockholm')
    end

    it 'returns 404 when profile does not exist' do
      get '/api/v1/profile'

      expect(response).to have_http_status(:not_found)
    end

    it 'serializes all profile attributes' do
      profile = Profile.create!(
        balance: 150.75,
        bio: 'Billing administrator',
        email: 'admin@billing.test',
        external_id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )

      get '/api/v1/profile'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['profile']['id']).to eq(profile.id)
      expect(body['profile']['name']).to eq('Admin')
      expect(body['profile']['email']).to eq('admin@billing.test')
      expect(body['profile']['bio']).to eq('Billing administrator')
      expect(body['profile']['timezone']).to eq('Europe/Stockholm')
      expect(body['profile']['external_id']).to eq('550e8400-e29b-41d4-a716-446655440000')
      expect(body['profile']['balance']).to eq('150.75')
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
      body = response.parsed_body
      expect(body['profile']['name']).to eq('Admin')
      expect(body['profile']['timezone']).to eq('Europe/Stockholm')
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
      body = response.parsed_body
      expect(body['profile']['bio']).to eq('Updated bio')
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
