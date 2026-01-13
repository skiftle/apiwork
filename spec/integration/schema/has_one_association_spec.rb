# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'has_one Association', type: :request do
  describe 'GET /api/v1/users/:id with has_one association' do
    it 'does not include has_one association by default' do
      user = User.create!(email: 'jane@customer.com', name: 'Jane Doe')
      Profile.create!(user:, bio: 'Developer bio', timezone: 'UTC')

      get "/api/v1/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['user']).not_to have_key('profile')
    end
  end

  describe 'has_one association in schema definition' do
    it 'schema has has_one association defined' do
      associations = Api::V1::UserSchema.associations
      profile_assoc = associations[:profile]

      expect(profile_assoc).to be_present
      expect(profile_assoc.type).to eq(:has_one)
    end

    it 'has_one association is singular' do
      associations = Api::V1::UserSchema.associations
      profile_assoc = associations[:profile]

      expect(profile_assoc.singular?).to be(true)
    end
  end

  describe 'has_one association in introspection' do
    it 'includes has_one in schema introspection' do
      api_class = Apiwork::API.find!('/api/v1')
      introspection = api_class.introspect

      user_resource = introspection.resources[:users]
      expect(user_resource).to be_present

      show_action = user_resource.actions[:show]
      expect(show_action).to be_present
    end
  end
end
