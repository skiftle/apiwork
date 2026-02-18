# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation STI type resolution', type: :integration do
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

  describe 'serialize' do
    it 'maps PersonCustomer type to person' do
      result = Api::V1::CustomerRepresentation.serialize(person)

      expect(result[:type]).to eq('person')
    end

    it 'maps CompanyCustomer type to company' do
      result = Api::V1::CustomerRepresentation.serialize(company)

      expect(result[:type]).to eq('company')
    end

    it 'includes PersonCustomer-specific attributes' do
      result = Api::V1::CustomerRepresentation.serialize(person)

      expect(result[:name]).to eq('Anna Svensson')
      expect(result[:born_on]).to eq(Date.new(1990, 5, 15))
    end

    it 'includes CompanyCustomer-specific attributes' do
      result = Api::V1::CustomerRepresentation.serialize(company)

      expect(result[:name]).to eq('Acme Corp')
      expect(result[:industry]).to eq('Technology')
      expect(result[:registration_number]).to eq('REG-123')
    end

    it 'serializes mixed collection with correct types' do
      results = Api::V1::CustomerRepresentation.serialize([person, company])

      types = results.map { |r| r[:type] }
      expect(types).to contain_exactly('person', 'company')
    end
  end

  describe 'deserialize' do
    it 'maps person type to PersonCustomer' do
      result = Api::V1::CustomerRepresentation.deserialize({ name: 'Anna Svensson', type: 'person' })

      expect(result[:type]).to eq('PersonCustomer')
    end

    it 'maps company type to CompanyCustomer' do
      result = Api::V1::CustomerRepresentation.deserialize({ name: 'Acme Corp', type: 'company' })

      expect(result[:type]).to eq('CompanyCustomer')
    end
  end
end
