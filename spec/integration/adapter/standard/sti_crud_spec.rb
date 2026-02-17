# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'STI CRUD operations', type: :request do
  let!(:person) do
    PersonCustomer.create!(
      born_on: Date.new(1990, 5, 15),
      email: 'ANNA@EXAMPLE.COM',
      name: 'Anna Svensson',
    )
  end

  let!(:company) do
    CompanyCustomer.create!(
      email: 'BILLING@ACME.COM',
      industry: 'Technology',
      name: 'Acme Corp',
      registration_number: 'REG-123',
    )
  end

  describe 'POST /api/v1/customers' do
    it 'creates PersonCustomer when type is person' do
      post '/api/v1/customers',
           as: :json,
           params: {
             customer: {
               born_on: '1985-03-20',
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

    it 'creates CompanyCustomer when type is company' do
      post '/api/v1/customers',
           as: :json,
           params: {
             customer: {
               email: 'billing@acme.com',
               industry: 'Finance',
               name: 'Acme Corp',
               registration_number: 'NEW-789',
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
    it 'preserves STI type after update' do
      patch "/api/v1/customers/#{person.id}",
            as: :json,
            params: { customer: { name: 'Updated Person' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['customer']['type']).to eq('person')

      person.reload
      expect(person.type).to eq('PersonCustomer')
      expect(person.name).to eq('Updated Person')
    end

    it 'updates CompanyCustomer specific attributes' do
      patch "/api/v1/customers/#{company.id}",
            as: :json,
            params: { customer: { industry: 'Healthcare' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['customer']['industry']).to eq('Healthcare')
      expect(json['customer']['type']).to eq('company')
    end
  end

  describe 'DELETE /api/v1/customers/:id' do
    it 'deletes PersonCustomer' do
      expect do
        delete "/api/v1/customers/#{person.id}"
      end.to change(PersonCustomer, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes CompanyCustomer' do
      expect do
        delete "/api/v1/customers/#{company.id}"
      end.to change(CompanyCustomer, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
