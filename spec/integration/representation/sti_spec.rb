# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation STI type resolution', type: :integration do
  let!(:customer1) do
    PersonCustomer.create!(
      born_on: '1985-06-15',
      email: 'ANNA@EXAMPLE.COM',
      name: 'Anna Svensson',
    )
  end

  let!(:customer2) do
    CompanyCustomer.create!(
      email: 'BILLING@ACME.COM',
      industry: 'Technology',
      name: 'Acme Corp',
      registration_number: 'SE556000-0000',
    )
  end

  describe 'serialize' do
    it 'serializes PersonCustomer type as person' do
      result = Api::V1::CustomerRepresentation.serialize(customer1)

      expect(result[:type]).to eq('person')
    end

    it 'serializes CompanyCustomer type as company' do
      result = Api::V1::CustomerRepresentation.serialize(customer2)

      expect(result[:type]).to eq('company')
    end

    it 'serializes PersonCustomer-specific attributes' do
      result = Api::V1::CustomerRepresentation.serialize(customer1)

      expect(result[:name]).to eq('Anna Svensson')
      expect(result[:born_on]).to eq(Date.new(1985, 6, 15))
    end

    it 'serializes CompanyCustomer-specific attributes' do
      result = Api::V1::CustomerRepresentation.serialize(customer2)

      expect(result[:name]).to eq('Acme Corp')
      expect(result[:industry]).to eq('Technology')
      expect(result[:registration_number]).to eq('SE556000-0000')
    end

    it 'serializes mixed collection with correct types' do
      results = Api::V1::CustomerRepresentation.serialize([customer1, customer2])

      types = results.map { |r| r[:type] }
      expect(types).to contain_exactly('person', 'company')
    end
  end

  describe 'deserialize' do
    it 'deserializes person type to PersonCustomer' do
      result = Api::V1::CustomerRepresentation.deserialize({ name: 'Anna Svensson', type: 'person' })

      expect(result[:type]).to eq('PersonCustomer')
    end

    it 'deserializes company type to CompanyCustomer' do
      result = Api::V1::CustomerRepresentation.deserialize({ name: 'Acme Corp', type: 'company' })

      expect(result[:type]).to eq('CompanyCustomer')
    end
  end
end
