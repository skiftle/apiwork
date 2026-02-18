# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation association serialization', type: :integration do
  let!(:customer1) { PersonCustomer.create!(email: 'ANNA@EXAMPLE.COM', name: 'Anna Svensson') }

  let!(:address1) do
    Address.create!(
      city: 'Stockholm',
      country: 'SE',
      customer: customer1,
      street: '123 Main St',
      zip: '111 22',
    )
  end

  context 'without include' do
    it 'serializes without optional association key' do
      result = Api::V1::CustomerRepresentation.serialize(customer1)

      expect(result).not_to have_key(:address)
    end
  end

  context 'with include' do
    it 'serializes address data when included' do
      result = Api::V1::CustomerRepresentation.serialize(customer1, include: { address: true })

      expect(result[:address][:street]).to eq('123 Main St')
      expect(result[:address][:city]).to eq('Stockholm')
      expect(result[:address][:zip]).to eq('111 22')
      expect(result[:address][:country]).to eq('SE')
    end

    it 'serializes has_one association as hash' do
      result = Api::V1::CustomerRepresentation.serialize(customer1, include: { address: true })

      expect(result[:address]).to be_a(Hash)
    end
  end

  context 'with nil association' do
    it 'serializes nil when association is missing' do
      customer2 = CompanyCustomer.create!(email: 'BILLING@ACME.COM', industry: 'Technology', name: 'Acme Corp')

      result = Api::V1::CustomerRepresentation.serialize(customer2, include: { address: true })

      expect(result[:address]).to be_nil
    end
  end

  context 'with collection' do
    it 'serializes association for each record in collection' do
      results = Api::V1::CustomerRepresentation.serialize([customer1], include: { address: true })

      expect(results.length).to eq(1)
      expect(results.first[:address][:street]).to eq('123 Main St')
    end
  end

  context 'when association is destroyed' do
    it 'serializes nil after association is destroyed' do
      address1.destroy!

      result = Api::V1::CustomerRepresentation.serialize(customer1.reload, include: { address: true })

      expect(result[:address]).to be_nil
    end
  end
end
