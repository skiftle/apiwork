# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'STI', type: :request do
  describe 'POST /api/v1/customers' do
    it 'creates PersonCustomer with type person' do
      post '/api/v1/customers',
           as: :json,
           params: {
             customer: {
               born_on: '1985-06-15',
               email: 'anna@example.com',
               name: 'Anna Svensson',
               type: 'person',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['customer']['type']).to eq('person')
      expect(PersonCustomer.last.name).to eq('Anna Svensson')
    end

    it 'creates CompanyCustomer with type company' do
      post '/api/v1/customers',
           as: :json,
           params: {
             customer: {
               email: 'billing@acme.com',
               industry: 'Technology',
               name: 'Acme Corp',
               registration_number: 'SE556000-0000',
               type: 'company',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['customer']['type']).to eq('company')
      expect(CompanyCustomer.last.name).to eq('Acme Corp')
    end
  end

  describe 'PATCH /api/v1/customers/:id' do
    let!(:customer1) do
      PersonCustomer.create!(born_on: '1985-06-15', email: 'anna@example.com', name: 'Anna Svensson')
    end

    it 'preserves STI type after update' do
      patch "/api/v1/customers/#{customer1.id}",
            as: :json,
            params: { customer: { name: 'Updated Person' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['customer']['type']).to eq('person')
      customer1.reload
      expect(customer1.type).to eq('PersonCustomer')
      expect(customer1.name).to eq('Updated Person')
    end

    it 'updates CompanyCustomer-specific attributes' do
      company = CompanyCustomer.create!(
        email: 'billing@acme.com',
        industry: 'Technology',
        name: 'Acme Corp',
        registration_number: 'SE556000-0000',
      )

      patch "/api/v1/customers/#{company.id}",
            as: :json,
            params: { customer: { industry: 'Healthcare' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['customer']['industry']).to eq('Healthcare')
      expect(json['customer']['type']).to eq('company')
    end
  end

  describe 'GET /api/v1/customers' do
    let!(:customer1) do
      PersonCustomer.create!(born_on: '1985-06-15', email: 'anna@example.com', name: 'Anna Svensson')
    end
    let!(:customer2) do
      CompanyCustomer.create!(
        email: 'billing@acme.com',
        industry: 'Technology',
        name: 'Acme Corp',
        registration_number: 'SE556000-0000',
      )
    end

    it 'returns mixed types with correct type field' do
      get '/api/v1/customers'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      types = json['customers'].map { |c| c['type'] }
      expect(types).to contain_exactly('person', 'company')
    end
  end

  describe 'DELETE /api/v1/customers/:id' do
    let!(:customer1) do
      PersonCustomer.create!(born_on: '1985-06-15', email: 'anna@example.com', name: 'Anna Svensson')
    end

    it 'deletes PersonCustomer' do
      expect do
        delete "/api/v1/customers/#{customer1.id}"
      end.to change(PersonCustomer, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes CompanyCustomer' do
      company = CompanyCustomer.create!(
        email: 'billing@acme.com',
        industry: 'Technology',
        name: 'Acme Corp',
        registration_number: 'SE556000-0000',
      )

      expect do
        delete "/api/v1/customers/#{company.id}"
      end.to change(CompanyCustomer, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
