# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'STI (Single Table Inheritance) API', type: :request do
  before do
    # Clean up any leftover clients from previous runs
    Client.destroy_all
  end

  describe 'GET /api/v1/clients' do
    let!(:person_client) do
      PersonClient.create!(
        birth_date: Date.new(1990, 5, 15),
        email: 'alice@example.com',
        name: 'Alice',
      )
    end

    let!(:company_client) do
      CompanyClient.create!(
        email: 'contact@acme.com',
        industry: 'Technology',
        name: 'Acme Corp',
        registration_number: 'REG-123',
      )
    end

    it 'returns mixed list of client types' do
      get '/api/v1/clients'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['clients'].length).to eq(2)
    end

    it 'includes discriminator field for each client' do
      get '/api/v1/clients'

      json = JSON.parse(response.body)
      kinds = json['clients'].map { |c| c['kind'] }

      expect(kinds).to contain_exactly('person', 'company')
    end

    it 'serializes PersonClient with birth_date' do
      get '/api/v1/clients'

      json = JSON.parse(response.body)
      person = json['clients'].find { |c| c['kind'] == 'person' }

      expect(person['name']).to eq('Alice')
      expect(person['email']).to eq('alice@example.com')
      expect(person['birth_date']).to eq('1990-05-15')
    end

    it 'serializes CompanyClient with industry and registration_number' do
      get '/api/v1/clients'

      json = JSON.parse(response.body)
      company = json['clients'].find { |c| c['kind'] == 'company' }

      expect(company['name']).to eq('Acme Corp')
      expect(company['industry']).to eq('Technology')
      expect(company['registration_number']).to eq('REG-123')
    end
  end

  describe 'GET /api/v1/clients/:id' do
    let!(:person_client) do
      PersonClient.create!(
        birth_date: Date.new(1985, 3, 20),
        email: 'bob@example.com',
        name: 'Bob',
      )
    end

    let!(:company_client) do
      CompanyClient.create!(
        email: 'info@widgets.com',
        industry: 'Manufacturing',
        name: 'Widgets Inc',
        registration_number: 'WID-456',
      )
    end

    it 'returns PersonClient with correct schema' do
      get "/api/v1/clients/#{person_client.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['client']['kind']).to eq('person')
      expect(json['client']['name']).to eq('Bob')
      expect(json['client']['birth_date']).to eq('1985-03-20')
    end

    it 'returns CompanyClient with correct schema' do
      get "/api/v1/clients/#{company_client.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['client']['kind']).to eq('company')
      expect(json['client']['name']).to eq('Widgets Inc')
      expect(json['client']['industry']).to eq('Manufacturing')
      expect(json['client']['registration_number']).to eq('WID-456')
    end
  end

  describe 'POST /api/v1/clients' do
    it 'creates PersonClient when kind is person' do
      post '/api/v1/clients',
           as: :json,
           params: {
             client: {
               birth_date: '1995-08-10',
               email: 'new@example.com',
               kind: 'person',
               name: 'New Person',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['client']['kind']).to eq('person')
      expect(json['client']['name']).to eq('New Person')
      expect(json['client']['birth_date']).to eq('1995-08-10')

      expect(PersonClient.last.name).to eq('New Person')
    end

    it 'creates CompanyClient when kind is company' do
      post '/api/v1/clients',
           as: :json,
           params: {
             client: {
               email: 'new@company.com',
               industry: 'Finance',
               kind: 'company',
               name: 'New Company',
               registration_number: 'NEW-789',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['client']['kind']).to eq('company')
      expect(json['client']['name']).to eq('New Company')
      expect(json['client']['industry']).to eq('Finance')

      expect(CompanyClient.last.name).to eq('New Company')
    end
  end

  describe 'PATCH /api/v1/clients/:id' do
    let!(:person_client) do
      PersonClient.create!(
        birth_date: Date.new(1990, 1, 1),
        email: 'update@example.com',
        name: 'Update Me',
      )
    end

    let!(:company_client) do
      CompanyClient.create!(
        email: 'update@corp.com',
        industry: 'Retail',
        name: 'Update Corp',
        registration_number: 'UPD-001',
      )
    end

    it 'updates PersonClient correctly' do
      patch "/api/v1/clients/#{person_client.id}",
            as: :json,
            params: { client: { name: 'Updated Person' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['client']['name']).to eq('Updated Person')
      expect(json['client']['kind']).to eq('person')

      person_client.reload
      expect(person_client.name).to eq('Updated Person')
    end

    it 'updates CompanyClient correctly' do
      patch "/api/v1/clients/#{company_client.id}",
            as: :json,
            params: { client: { industry: 'Healthcare' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['client']['industry']).to eq('Healthcare')
      expect(json['client']['kind']).to eq('company')

      company_client.reload
      expect(company_client.industry).to eq('Healthcare')
    end

    it 'preserves STI type after update' do
      patch "/api/v1/clients/#{person_client.id}",
            as: :json,
            params: { client: { name: 'Still a Person' } }

      person_client.reload
      expect(person_client.type).to eq('PersonClient')
    end
  end

  describe 'DELETE /api/v1/clients/:id' do
    let!(:person_client) do
      PersonClient.create!(
        birth_date: Date.new(1990, 1, 1),
        email: 'delete@example.com',
        name: 'Delete Me',
      )
    end

    let!(:company_client) do
      CompanyClient.create!(
        email: 'delete@corp.com',
        industry: 'Services',
        name: 'Delete Corp',
        registration_number: 'DEL-001',
      )
    end

    it 'deletes PersonClient' do
      expect do
        delete "/api/v1/clients/#{person_client.id}"
      end.to change(PersonClient, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes CompanyClient' do
      expect do
        delete "/api/v1/clients/#{company_client.id}"
      end.to change(CompanyClient, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
