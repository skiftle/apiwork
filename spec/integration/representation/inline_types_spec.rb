# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation JSON column handling', type: :integration do
  let!(:customer1) { PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp') }

  describe 'serialize' do
    it 'serializes metadata hash' do
      invoice1 = Invoice.create!(
        customer: customer1,
        metadata: { 'priority' => 'high', 'department' => 'billing' },
        number: 'INV-001',
        status: :draft,
      )

      result = Api::V1::InvoiceRepresentation.serialize(invoice1)

      expect(result[:metadata]).to eq({ 'priority' => 'high', 'department' => 'billing' })
    end

    it 'serializes nil metadata' do
      invoice1 = Invoice.create!(
        customer: customer1,
        metadata: nil,
        number: 'INV-001',
        status: :draft,
      )

      result = Api::V1::InvoiceRepresentation.serialize(invoice1)

      expect(result[:metadata]).to be_nil
    end

    it 'serializes metadata with nested structure' do
      invoice1 = Invoice.create!(
        customer: customer1,
        metadata: { 'tags' => %w[priority urgent], 'config' => { 'auto_send' => true } },
        number: 'INV-001',
        status: :draft,
      )

      result = Api::V1::InvoiceRepresentation.serialize(invoice1)

      expect(result[:metadata]['tags']).to eq(%w[priority urgent])
      expect(result[:metadata]['config']).to eq({ 'auto_send' => true })
    end
  end

  describe 'deserialize' do
    it 'deserializes metadata hash' do
      result = Api::V1::InvoiceRepresentation.deserialize(
        {
          metadata: { 'priority' => 'high', 'department' => 'billing' },
          number: 'INV-001',
          status: 'draft',
        },
      )

      expect(result[:metadata]).to eq({ 'priority' => 'high', 'department' => 'billing' })
    end

    it 'deserializes nil metadata' do
      result = Api::V1::InvoiceRepresentation.deserialize(
        {
          metadata: nil,
          number: 'INV-001',
          status: 'draft',
        },
      )

      expect(result[:metadata]).to be_nil
    end

    it 'deserializes metadata with nested structure' do
      result = Api::V1::InvoiceRepresentation.deserialize(
        {
          metadata: { 'tags' => %w[priority urgent], 'config' => { 'auto_send' => true } },
          number: 'INV-001',
          status: 'draft',
        },
      )

      expect(result[:metadata]['tags']).to eq(%w[priority urgent])
      expect(result[:metadata]['config']).to eq({ 'auto_send' => true })
    end
  end
end
