# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Writable context filtering (on: [:create] / on: [:update])', type: :request do
  describe 'writable: { on: [:create] } - only writable on create' do
    it 'allows setting bio during create' do
      author_params = {
        author: {
          name: 'Jane Doe',
          bio: 'Software engineer and writer'
        }
      }

      post '/api/v1/authors', params: author_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['author']['name']).to eq('Jane Doe')
      expect(json['author']['bio']).to eq('Software engineer and writer')
      expect(json['author']['verified']).to be_falsey # Not writable on create, defaults to nil/false
    end

    it 'rejects verified field during create (not writable on create)' do
      author_params = {
        author: {
          name: 'Jane Doe',
          verified: true # Not writable on create
        }
      }

      post '/api/v1/authors', params: author_params, as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['errors']).to be_present
      issue = json['errors'].find { |i| i['path'].include?('verified') }
      expect(issue).to be_present
      expect(issue['code']).to eq('field_unknown')
    end

    it 'rejects bio field during update (not writable on update)' do
      author = Author.create!(name: 'Original Name', bio: 'Original Bio')

      patch "/api/v1/authors/#{author.id}",
            params: { author: { bio: 'Attempted Update' } },
            as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      expect(json['errors']).to be_present
      issue = json['errors'].find { |i| i['path'].include?('bio') }
      expect(issue).to be_present
      expect(issue['code']).to eq('field_unknown')

      author.reload
      expect(author.bio).to eq('Original Bio') # Verify DB unchanged
    end

    it 'allows updating name but rejects bio during update' do
      author = Author.create!(name: 'Original Name', bio: 'Original Bio')

      patch "/api/v1/authors/#{author.id}",
            params: { author: { name: 'Updated Name', bio: 'Should be rejected' } },
            as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['errors'].find { |i| i['path'].include?('bio') }
      expect(issue).to be_present
      expect(issue['code']).to eq('field_unknown')

      author.reload
      expect(author.name).to eq('Original Name') # Name not updated due to validation error
      expect(author.bio).to eq('Original Bio')
    end
  end

  describe 'writable: { on: [:update] } - only writable on update' do
    it 'rejects verified field during create (already tested above)' do
      # This is already covered by the test in the previous describe block
      # Just confirming verified is not writable on create
      author_params = {
        author: {
          name: 'John Smith'
        }
      }

      post '/api/v1/authors', params: author_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['author']['name']).to eq('John Smith')
      expect(json['author']['verified']).to be_falsey # Defaults to nil/false
    end

    it 'allows setting verified during update' do
      author = Author.create!(name: 'Jane Doe')

      expect(author.verified).to be_falsey # nil or false

      patch "/api/v1/authors/#{author.id}",
            params: { author: { verified: true } },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['author']['verified']).to be(true)

      author.reload
      expect(author.verified).to be(true)
    end

    it 'allows updating other writable fields while setting verified' do
      author = Author.create!(name: 'Original Name', verified: false)

      patch "/api/v1/authors/#{author.id}",
            params: { author: { name: 'Updated Name', verified: true } },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['author']['name']).to eq('Updated Name')
      expect(json['author']['verified']).to be(true)

      author.reload
      expect(author.name).to eq('Updated Name')
      expect(author.verified).to be(true)
    end
  end

  describe 'writable: true - writable on both create and update' do
    it 'allows setting name during create' do
      author_params = {
        author: {
          name: 'Test Author'
        }
      }

      post '/api/v1/authors', params: author_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['author']['name']).to eq('Test Author')
    end

    it 'allows updating name during update' do
      author = Author.create!(name: 'Original Name')

      patch "/api/v1/authors/#{author.id}",
            params: { author: { name: 'Updated Name' } },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['author']['name']).to eq('Updated Name')

      author.reload
      expect(author.name).to eq('Updated Name')
    end
  end

  describe 'combined constraints' do
    it 'correctly filters context-specific fields on create vs update' do
      # Create with bio (allowed), verified rejected with field_unknown
      post '/api/v1/authors',
           params: { author: { name: 'Author', bio: 'Initial Bio', verified: true } },
           as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['errors'].find { |i| i['path'].include?('verified') }
      expect(issue['code']).to eq('field_unknown')

      # Create without verified field - should succeed
      post '/api/v1/authors',
           params: { author: { name: 'Author', bio: 'Initial Bio' } },
           as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      author_id = json['author']['id']

      expect(json['author']['bio']).to eq('Initial Bio')
      expect(json['author']['verified']).to be_falsey

      # Update with bio (rejected) and verified (allowed)
      patch "/api/v1/authors/#{author_id}",
            params: { author: { bio: 'Updated Bio', verified: true } },
            as: :json

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)

      issue = json['errors'].find { |i| i['path'].include?('bio') }
      expect(issue['code']).to eq('field_unknown')

      # Update only verified (allowed on update)
      patch "/api/v1/authors/#{author_id}",
            params: { author: { verified: true } },
            as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['author']['bio']).to eq('Initial Bio') # Unchanged
      expect(json['author']['verified']).to be(true)     # Updated

      author = Author.find(author_id)
      expect(author.bio).to eq('Initial Bio')
      expect(author.verified).to be(true)
    end
  end
end
