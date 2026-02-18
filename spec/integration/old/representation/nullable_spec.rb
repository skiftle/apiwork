# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation nullable attributes', type: :integration do
  describe 'serialize nil nullable attribute' do
    it 'returns nil for nullable email' do
      customer = CompanyCustomer.create!(email: nil, industry: 'Technology', name: 'Acme Corp')

      result = Api::V1::CustomerRepresentation.serialize(customer)

      expect(result[:email]).to be_nil
    end
  end

  describe 'serialize nil optional fields' do
    it 'returns nil for unset notes' do
      customer = PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp')
      invoice = Invoice.create!(customer:, number: 'INV-001')

      result = Api::V1::InvoiceRepresentation.serialize(invoice)

      expect(result[:notes]).to be_nil
    end

    it 'returns nil for unset due_on' do
      customer = PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp')
      invoice = Invoice.create!(customer:, number: 'INV-001')

      result = Api::V1::InvoiceRepresentation.serialize(invoice)

      expect(result[:due_on]).to be_nil
    end
  end

  describe 'deserialize nil through decode lambda' do
    it 'handles nil email through decode safely' do
      result = Api::V1::CustomerRepresentation.deserialize({ email: nil, name: 'Acme Corp', type: 'company' })

      expect(result[:email]).to be_nil
    end
  end
end
