# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Min and Max validation on params', type: :request do
  describe 'min: validation on string params' do
    it 'rejects strings shorter than min length' do
      user_params = {
        user: {
          name: 'A', # Only 1 character, min is 2
          email: 'test@example.com'
        }
      }

      post '/api/v1/users', params: user_params, as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['ok']).to be(false)
      expect(json['issues']).to be_present
      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue).to be_present
      expect(issue['code']).to eq('string_too_short')
    end

    it 'accepts strings equal to min length' do
      user_params = {
        user: {
          name: 'AB', # Exactly 2 characters
          email: 'test@example.com'
        }
      }

      post '/api/v1/users', params: user_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
    end

    it 'accepts strings longer than min but within max' do
      user_params = {
        user: {
          name: 'John Doe', # 8 characters, between min(2) and max(50)
          email: 'test@example.com'
        }
      }

      post '/api/v1/users', params: user_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['user']['name']).to eq('John Doe')
    end
  end

  describe 'max: validation on string params' do
    it 'rejects strings longer than max length' do
      user_params = {
        user: {
          name: 'A' * 51, # 51 characters, max is 50
          email: 'test@example.com'
        }
      }

      post '/api/v1/users', params: user_params, as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['ok']).to be(false)
      expect(json['issues']).to be_present
      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('string_too_long')
    end

    it 'accepts strings equal to max length' do
      user_params = {
        user: {
          name: 'A' * 50, # Exactly 50 characters
          email: 'test@example.com'
        }
      }

      post '/api/v1/users', params: user_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
    end

    it 'accepts strings shorter than max' do
      user_params = {
        user: {
          name: 'Short', # 5 characters, well under max(50)
          email: 'test@example.com'
        }
      }

      post '/api/v1/users', params: user_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
    end
  end

  describe 'min and max validation together' do
    it 'enforces both constraints' do
      # Too short (violates min)
      post '/api/v1/users', params: { user: { name: 'X', email: 'a@b.com' } }, as: :json
      expect(response).to have_http_status(:bad_request)

      # Just right
      post '/api/v1/users', params: { user: { name: 'Valid Name', email: 'c@d.com' } }, as: :json
      expect(response).to have_http_status(:created)

      # Too long (violates max)
      post '/api/v1/users', params: { user: { name: 'X' * 51, email: 'e@f.com' } }, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'min/max validation on update operations' do
    let!(:user) { User.create!(name: 'Original Name', email: 'original@test.com') }

    it 'validates min length on updates' do
      patch "/api/v1/users/#{user.id}", params: { user: { name: 'X' } }, as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('string_too_short')
    end

    it 'validates max length on updates' do
      patch "/api/v1/users/#{user.id}", params: { user: { name: 'A' * 51 } }, as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('string_too_long')
    end

    it 'accepts valid length updates' do
      patch "/api/v1/users/#{user.id}", params: { user: { name: 'Updated Name' } }, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['user']['name']).to eq('Updated Name')

      user.reload
      expect(user.name).to eq('Updated Name')
    end
  end

  describe 'error messages' do
    it 'provides clear error message for min violation' do
      post '/api/v1/users', params: { user: { name: 'X', email: 'test@example.com' } }, as: :json

      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['path'].include?('name') }

      expect(issue['code']).to eq('string_too_short')
      expect(issue['path']).to eq(%w[user name])
    end

    it 'provides clear error message for max violation' do
      post '/api/v1/users', params: { user: { name: 'X' * 51, email: 'test@example.com' } }, as: :json

      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['path'].include?('name') }

      expect(issue['code']).to eq('string_too_long')
      expect(issue['path']).to eq(%w[user name])
    end
  end
end
