# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation association serialization', type: :integration do
  let!(:customer) do
    PersonCustomer.create!(
      email: 'BILLING@ACME.COM',
      name: 'Acme Corp',
    )
  end

  let!(:address) do
    Address.create!(
      city: 'Stockholm',
      country: 'SE',
      customer: customer,
      street: 'Kungsgatan 1',
      zip: '111 43',
    )
  end

  context 'without include' do
    it 'excludes optional association by default' do
      result = Api::V1::CustomerRepresentation.serialize(customer)

      expect(result).not_to have_key(:address)
    end
  end

  context 'with include' do
    it 'includes address data when requested' do
      result = Api::V1::CustomerRepresentation.serialize(customer, include: { address: true })

      expect(result[:address]).to be_present
      expect(result[:address][:street]).to eq('Kungsgatan 1')
      expect(result[:address][:city]).to eq('Stockholm')
      expect(result[:address][:zip]).to eq('111 43')
      expect(result[:address][:country]).to eq('SE')
    end

    it 'returns a hash not an array' do
      result = Api::V1::CustomerRepresentation.serialize(customer, include: { address: true })

      expect(result[:address]).to be_a(Hash)
    end
  end

  context 'with nil association' do
    it 'returns nil when association is missing' do
      customer_without_address = PersonCustomer.create!(
        email: 'ANNA@EXAMPLE.COM',
        name: 'Anna Svensson',
      )

      result = Api::V1::CustomerRepresentation.serialize(customer_without_address, include: { address: true })

      expect(result[:address]).to be_nil
    end
  end

  context 'when association is destroyed' do
    it 'returns nil after address is destroyed' do
      address.destroy!

      result = Api::V1::CustomerRepresentation.serialize(customer.reload, include: { address: true })

      expect(result[:address]).to be_nil
    end
  end

  context 'with collection' do
    it 'includes association for each record' do
      results = Api::V1::CustomerRepresentation.serialize([customer], include: { address: true })

      expect(results.first[:address]).to be_present
      expect(results.first[:address][:street]).to eq('Kungsgatan 1')
    end
  end
end
