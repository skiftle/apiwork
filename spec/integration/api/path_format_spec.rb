# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'path_format Configuration', type: :request do
  describe 'API with path_format :kebab' do
    it 'routes to kebab-case paths' do
      user = User.create!(email: 'test@example.com', name: 'Test')
      UserProfile.create!(user:, bio: 'Test', timezone: 'UTC')

      get '/api/v2/user-profiles'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['userProfiles']).to be_an(Array)
    end

    it 'routes show action with kebab-case path' do
      user = User.create!(email: 'test@example.com', name: 'Test')
      profile = UserProfile.create!(user:, bio: 'Test', timezone: 'UTC')

      get "/api/v2/user-profiles/#{profile.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'routes create action with kebab-case path' do
      post '/api/v2/user-profiles',
           as: :json,
           params: {
             userProfile: {
               bio: 'New bio',
               timezone: 'UTC',
             },
           }

      expect(response).to have_http_status(:created)
    end

    it 'routes update action with kebab-case path' do
      user = User.create!(email: 'test@example.com', name: 'Test')
      profile = UserProfile.create!(user:, bio: 'Old', timezone: 'UTC')

      patch "/api/v2/user-profiles/#{profile.id}",
            as: :json,
            params: {
              userProfile: { bio: 'Updated' },
            }

      expect(response).to have_http_status(:ok)
    end

    it 'routes destroy action with kebab-case path' do
      user = User.create!(email: 'test@example.com', name: 'Test')
      profile = UserProfile.create!(user:, bio: 'Delete', timezone: 'UTC')

      delete "/api/v2/user-profiles/#{profile.id}"

      expect(response).to have_http_status(:no_content)
    end
  end

  describe 'API with path_format :kebab combined with key_format :camel' do
    it 'uses kebab-case in URL but camelCase in response keys' do
      user = User.create!(email: 'test@example.com', name: 'Test')
      UserProfile.create!(user:, bio: 'Test', timezone: 'UTC')

      get '/api/v2/user-profiles'

      json = JSON.parse(response.body)
      expect(json).to have_key('userProfiles')
      expect(json['userProfiles'].first).to have_key('avatarUrl')
      expect(json['userProfiles'].first).to have_key('createdAt')
    end

    it 'accepts camelCase keys in request body' do
      post '/api/v2/user-profiles',
           as: :json,
           params: {
             userProfile: {
               avatarUrl: 'https://example.com/avatar.png',
               bio: 'Test',
               timezone: 'UTC',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['userProfile']['avatarUrl']).to eq('https://example.com/avatar.png')
    end
  end

  describe 'path_format in introspection' do
    it 'reflects path_format setting in API introspection' do
      api = Apiwork::API.find('/api/v2')

      expect(api.path_format).to eq(:kebab)
    end
  end

  describe 'path_format in OpenAPI export' do
    it 'uses kebab-case paths in OpenAPI spec' do
      generator = Apiwork::Export::OpenAPI.new('/api/v2')
      spec = generator.generate

      paths = spec[:paths].keys
      expect(paths).to include('/user-profiles')
      expect(paths).to include('/user-profiles/{id}')
    end
  end
end
