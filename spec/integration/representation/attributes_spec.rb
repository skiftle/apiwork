# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation attribute serialization', type: :integration do
  let!(:customer1) { PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp') }

  describe 'serialize' do
    it 'serializes all attribute types' do
      invoice1 = Invoice.create!(
        customer: customer1,
        due_on: Date.new(2026, 3, 15),
        metadata: { 'priority' => 'high' },
        notes: 'Rush delivery',
        number: 'INV-001',
        sent: true,
        status: :draft,
      )

      result = Api::V1::InvoiceRepresentation.serialize(invoice1)

      expect(result[:number]).to eq('INV-001')
      expect(result[:status]).to eq('draft')
      expect(result[:due_on]).to eq(Date.new(2026, 3, 15))
      expect(result[:notes]).to eq('Rush delivery')
      expect(result[:sent]).to be(true)
      expect(result[:metadata]).to eq({ 'priority' => 'high' })
      expect(result[:id]).to eq(invoice1.id)
      expect(result[:created_at]).to eq(invoice1.created_at)
      expect(result[:updated_at]).to eq(invoice1.updated_at)
      expect(result[:customer_id]).to eq(customer1.id)
    end

    it 'serializes a collection of records' do
      invoice1 = Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft)
      invoice2 = Invoice.create!(customer: customer1, due_on: 2.days.from_now, number: 'INV-002', status: :sent)

      results = Api::V1::InvoiceRepresentation.serialize([invoice1, invoice2])

      expect(results.length).to eq(2)
      numbers = results.map { |r| r[:number] }
      expect(numbers).to contain_exactly('INV-001', 'INV-002')
    end

    it 'serializes read-only attributes in output' do
      invoice1 = Invoice.create!(customer: customer1, number: 'INV-001', status: :draft)

      result = Api::V1::InvoiceRepresentation.serialize(invoice1)

      expect(result).to have_key(:id)
      expect(result).to have_key(:created_at)
      expect(result).to have_key(:updated_at)
    end
  end

  describe 'deserialize' do
    it 'deserializes writable keys' do
      result = Api::V1::InvoiceRepresentation.deserialize(
        {
          customer_id: 1,
          due_on: '2026-03-15',
          notes: 'Rush delivery',
          number: 'INV-001',
          sent: true,
          status: 'draft',
        },
      )

      expect(result[:number]).to eq('INV-001')
      expect(result[:status]).to eq('draft')
      expect(result[:due_on]).to eq('2026-03-15')
      expect(result[:notes]).to eq('Rush delivery')
      expect(result[:sent]).to be(true)
      expect(result[:customer_id]).to eq(1)
    end

    it 'deserializes without read-only keys when not provided' do
      result = Api::V1::InvoiceRepresentation.deserialize(
        {
          number: 'INV-001',
          status: 'draft',
        },
      )

      expect(result).to have_key(:number)
      expect(result).to have_key(:status)
      expect(result).not_to have_key(:id)
      expect(result).not_to have_key(:created_at)
      expect(result).not_to have_key(:updated_at)
    end
  end

  describe 'profile attributes' do
    it 'serializes profile with format and deprecated attributes' do
      profile1 = Profile.create!(
        bio: 'Billing administrator',
        email: 'admin@billing.test',
        external_id: '550e8400-e29b-41d4-a716-446655440000',
        name: 'Admin',
        timezone: 'Europe/Stockholm',
      )

      result = Api::V1::ProfileRepresentation.serialize(profile1)

      expect(result[:name]).to eq('Admin')
      expect(result[:email]).to eq('admin@billing.test')
      expect(result[:bio]).to eq('Billing administrator')
      expect(result[:timezone]).to eq('Europe/Stockholm')
      expect(result[:external_id]).to eq('550e8400-e29b-41d4-a716-446655440000')
    end
  end
end
