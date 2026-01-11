# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Min and Max validation on params', type: :request do
  describe 'min: validation on string params' do
    it 'rejects strings shorter than min length' do
      user_params = {
        user: {
          email: 'jane@customer.com',
          name: 'A',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_present
      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue).to be_present
      expect(issue['code']).to eq('string_too_short')
    end

    it 'accepts strings equal to min length' do
      user_params = {
        user: {
          email: 'jane@customer.com',
          name: 'AB',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:created)
      JSON.parse(response.body)
    end

    it 'accepts strings longer than min but within max' do
      user_params = {
        user: {
          email: 'jane@customer.com',
          name: 'John Doe',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['user']['name']).to eq('John Doe')
    end
  end

  describe 'max: validation on string params' do
    it 'rejects strings longer than max length' do
      user_params = {
        user: {
          email: 'jane@customer.com',
          name: 'A' * 51,
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['issues']).to be_present
      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('string_too_long')
    end

    it 'accepts strings equal to max length' do
      user_params = {
        user: {
          email: 'jane@customer.com',
          name: 'A' * 50,
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:created)
      JSON.parse(response.body)
    end

    it 'accepts strings shorter than max' do
      user_params = {
        user: {
          email: 'jane@customer.com',
          name: 'Short',
        },
      }

      post '/api/v1/users', as: :json, params: user_params

      expect(response).to have_http_status(:created)
      JSON.parse(response.body)
    end
  end

  describe 'min and max validation together' do
    it 'enforces both constraints' do
      # Too short (violates min)
      post '/api/v1/users', as: :json, params: { user: { email: 'a@b.com', name: 'X' } }
      expect(response).to have_http_status(:bad_request)

      # Just right
      post '/api/v1/users', as: :json, params: { user: { email: 'c@d.com', name: 'Valid Name' } }
      expect(response).to have_http_status(:created)

      # Too long (violates max)
      post '/api/v1/users', as: :json, params: { user: { email: 'e@f.com', name: 'X' * 51 } }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'min/max validation on update operations' do
    let!(:user) { User.create!(email: 'jane@billing.com', name: 'Original Name') }

    it 'validates min length on updates' do
      patch "/api/v1/users/#{user.id}", as: :json, params: { user: { name: 'X' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('string_too_short')
    end

    it 'validates max length on updates' do
      patch "/api/v1/users/#{user.id}", as: :json, params: { user: { name: 'A' * 51 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['issues'].find { |i| i['path'].include?('name') }
      expect(issue['code']).to eq('string_too_long')
    end

    it 'accepts valid length updates' do
      patch "/api/v1/users/#{user.id}", as: :json, params: { user: { name: 'Updated Name' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['user']['name']).to eq('Updated Name')

      user.reload
      expect(user.name).to eq('Updated Name')
    end
  end

  describe 'error messages' do
    it 'provides clear error message for min violation' do
      post '/api/v1/users', as: :json, params: { user: { email: 'jane@customer.com', name: 'X' } }

      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['path'].include?('name') }

      expect(issue['code']).to eq('string_too_short')
      expect(issue['path']).to eq(%w[user name])
    end

    it 'provides clear error message for max violation' do
      post '/api/v1/users', as: :json, params: { user: { email: 'jane@customer.com', name: 'X' * 51 } }

      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['path'].include?('name') }

      expect(issue['code']).to eq('string_too_long')
      expect(issue['path']).to eq(%w[user name])
    end
  end
end
