# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation encode and decode', type: :integration do
  describe 'encode on serialize' do
    it 'transforms output value through encode lambda' do
      customer = PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp')

      result = Api::V1::CustomerRepresentation.serialize(customer)

      expect(result[:email]).to eq('billing@acme.com')
    end
  end

  describe 'decode on deserialize' do
    it 'transforms input value through decode lambda' do
      result = Api::V1::CustomerRepresentation.deserialize({ email: 'anna@example.com', name: 'Anna Svensson', type: 'person' })

      expect(result[:email]).to eq('ANNA@EXAMPLE.COM')
    end
  end

  describe 'nil safety' do
    it 'handles nil through encode safely' do
      customer = CompanyCustomer.create!(email: nil, industry: 'Technology', name: 'Acme Corp')

      result = Api::V1::CustomerRepresentation.serialize(customer)

      expect(result[:email]).to be_nil
    end

    it 'handles nil through decode safely' do
      result = Api::V1::CustomerRepresentation.deserialize({ email: nil, name: 'Acme Corp', type: 'company' })

      expect(result[:email]).to be_nil
    end
  end

  describe 'round-trip' do
    it 'maintains symmetry through deserialize, create, and serialize' do
      deserialized = Api::V1::CustomerRepresentation.deserialize({ email: 'anna@example.com', name: 'Anna Svensson', type: 'person' })

      expect(deserialized[:email]).to eq('ANNA@EXAMPLE.COM')

      customer = PersonCustomer.create!(deserialized.slice(:email, :name))

      result = Api::V1::CustomerRepresentation.serialize(customer)

      expect(result[:email]).to eq('anna@example.com')
    end
  end
end
