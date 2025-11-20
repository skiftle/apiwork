# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'STI (Single Table Inheritance) API', type: :request do
  # Ensure variant schemas are loaded before tests
  # This triggers Zeitwerk autoloading by referencing the schema classes
  before(:all) do
    Api::V1::CompanyClientSchema
  end

  let!(:person_client) do
    PersonClient.create!(
      name: 'Alice Smith',
      email: 'alice@example.com',
      birth_date: Date.new(1990, 5, 15)
    )
  end

  let!(:company_client) do
    CompanyClient.create!(
      name: 'Acme Corp',
      email: 'contact@acme.com',
      industry: 'Technology',
      registration_number: 'ABC123'
    )
  end

  let!(:service_for_person) do
    Service.create!(
      name: 'Personal Consulting',
      description: 'One-on-one consulting service',
      client: person_client
    )
  end

  let!(:service_for_company) do
    Service.create!(
      name: 'Enterprise Support',
      description: 'Full enterprise support package',
      client: company_client
    )
  end

  describe 'DSL and Schema Configuration' do
    it 'base schema has discriminator metadata' do
      expect(Api::V1::ClientSchema.discriminator_column).to eq(:type)
      expect(Api::V1::ClientSchema.discriminator_name).to eq(:kind)
      expect(Api::V1::ClientSchema.sti_base?).to be(true)
    end

    it 'variant schemas have variant metadata' do
      expect(Api::V1::PersonClientSchema.variant_tag).to eq(:person)
      expect(Api::V1::PersonClientSchema.sti_type).to eq('PersonClient')
      expect(Api::V1::PersonClientSchema.sti_variant?).to be(true)

      expect(Api::V1::CompanyClientSchema.variant_tag).to eq(:company)
      expect(Api::V1::CompanyClientSchema.sti_type).to eq('CompanyClient')
      expect(Api::V1::CompanyClientSchema.sti_variant?).to be(true)
    end

    it 'base schema registers variants' do
      variants = Api::V1::ClientSchema.variants
      expect(variants.keys).to contain_exactly(:person, :company)

      expect(variants[:person][:schema]).to eq(Api::V1::PersonClientSchema)
      expect(variants[:person][:sti_type]).to eq('PersonClient')

      expect(variants[:company][:schema]).to eq(Api::V1::CompanyClientSchema)
      expect(variants[:company][:sti_type]).to eq('CompanyClient')
    end

    it 'auto-marks base schema as abstract when variants register' do
      expect(Api::V1::ClientSchema.abstract?).to be(true)
    end
  end

  describe 'Serialization' do
    describe 'discriminator field' do
      it 'includes discriminator field in person variant' do
        serialized = Api::V1::PersonClientSchema.serialize(person_client)
        expect(serialized[:kind]).to eq('person')
      end

      it 'includes discriminator field in company variant' do
        serialized = Api::V1::CompanyClientSchema.serialize(company_client)
        expect(serialized[:kind]).to eq('company')
      end
    end

    describe 'variant-specific attributes' do
      it 'serializes person-specific attributes' do
        serialized = Api::V1::PersonClientSchema.serialize(person_client)
        expect(serialized[:birthDate]).to be_present
        expect(serialized.keys).not_to include(:industry, :registrationNumber)
      end

      it 'serializes company-specific attributes' do
        serialized = Api::V1::CompanyClientSchema.serialize(company_client)
        expect(serialized[:industry]).to eq('Technology')
        expect(serialized[:registrationNumber]).to eq('ABC123')
        expect(serialized.keys).not_to include(:birthDate)
      end
    end

    describe 'STI association serialization' do
      it 'routes person client to PersonClientSchema' do
        serialized = Api::V1::ServiceSchema.serialize(service_for_person, includes: { client: true })
        expect(serialized[:client]).to be_present
        expect(serialized[:client][:kind]).to eq('person')
        expect(serialized[:client][:birthDate]).to be_present
      end

      it 'routes company client to CompanyClientSchema' do
        serialized = Api::V1::ServiceSchema.serialize(service_for_company, includes: { client: true })
        expect(serialized[:client]).to be_present
        expect(serialized[:client][:kind]).to eq('company')
        expect(serialized[:client][:industry]).to eq('Technology')
      end
    end
  end

  describe 'GET /api/v1/clients' do
    it 'returns all clients with correct discriminator values' do
      get '/api/v1/clients'

      puts "Response status: #{response.status}"
      puts "Response body: #{response.body}" if response.status != 200

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['clients'].length).to eq(2)

      person = json['clients'].find { |c| c['kind'] == 'person' }
      company = json['clients'].find { |c| c['kind'] == 'company' }

      expect(person).to be_present
      expect(person['name']).to eq('Alice Smith')
      expect(person['birthDate']).to be_present

      expect(company).to be_present
      expect(company['name']).to eq('Acme Corp')
      expect(company['industry']).to eq('Technology')
    end

    it 'includes services association when requested' do
      get '/api/v1/clients', params: { include: { services: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      person = json['clients'].find { |c| c['kind'] == 'person' }
      expect(person['services']).to be_present
      expect(person['services'].length).to eq(1)
      expect(person['services'].first['name']).to eq('Personal Consulting')
    end
  end

  describe 'GET /api/v1/clients/:id' do
    it 'returns person client with discriminator' do
      get "/api/v1/clients/#{person_client.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['client']['kind']).to eq('person')
      expect(json['client']['name']).to eq('Alice Smith')
      expect(json['client']['birthDate']).to be_present
    end

    it 'returns company client with discriminator' do
      get "/api/v1/clients/#{company_client.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['client']['kind']).to eq('company')
      expect(json['client']['name']).to eq('Acme Corp')
      expect(json['client']['industry']).to eq('Technology')
    end
  end

  describe 'GET /api/v1/services with STI association' do
    it 'includes client association with correct variant routing' do
      get '/api/v1/services', params: { include: { client: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)

      personal_service = json['services'].find { |s| s['name'] == 'Personal Consulting' }
      expect(personal_service['client']).to be_present
      expect(personal_service['client']['kind']).to eq('person')
      expect(personal_service['client']['birthDate']).to be_present

      enterprise_service = json['services'].find { |s| s['name'] == 'Enterprise Support' }
      expect(enterprise_service['client']).to be_present
      expect(enterprise_service['client']['kind']).to eq('company')
      expect(enterprise_service['client']['industry']).to eq('Technology')
    end
  end

  describe 'GET /api/v1/services/:id with STI association' do
    it 'includes person client when requested' do
      get "/api/v1/services/#{service_for_person.id}", params: { include: { client: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['service']['client']).to be_present
      expect(json['service']['client']['kind']).to eq('person')
      expect(json['service']['client']['birthDate']).to be_present
    end

    it 'includes company client when requested' do
      get "/api/v1/services/#{service_for_company.id}", params: { include: { client: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['service']['client']).to be_present
      expect(json['service']['client']['kind']).to eq('company')
      expect(json['service']['client']['industry']).to eq('Technology')
    end
  end

  describe 'Type generation' do
    it 'generates discriminated union for STI associations' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Should have a union type for the client STI resource (uses root_key as name)
      expect(introspection[:types]).to have_key(:client)

      union_type = introspection[:types][:client]
      expect(union_type).to be_a(Hash)
      expect(union_type[:discriminator]).to eq(:kind)
      expect(union_type[:variants]).to be_an(Array)
      expect(union_type[:variants].length).to eq(2)

      # Verify variant tags
      variant_tags = union_type[:variants].map { |v| v[:tag] }
      expect(variant_tags).to contain_exactly('person', 'company')
    end

    it 'generates base types for each variant' do
      introspection = Apiwork::API.introspect('/api/v1')

      # PersonClient variant type
      expect(introspection[:types]).to have_key(:person_client)
      person_type = introspection[:types][:person_client]
      expect(person_type[:shape]).to have_key(:kind)
      expect(person_type[:shape]).to have_key(:name)
      expect(person_type[:shape]).to have_key(:birth_date)

      # CompanyClient variant type
      expect(introspection[:types]).to have_key(:company_client)
      company_type = introspection[:types][:company_client]
      expect(company_type[:shape]).to have_key(:kind)
      expect(company_type[:shape]).to have_key(:name)
      expect(company_type[:shape]).to have_key(:industry)
      expect(company_type[:shape]).to have_key(:registration_number)
    end
  end
end
