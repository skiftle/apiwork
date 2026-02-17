# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root key overrides', type: :request do
  let!(:customer) { Customer.create!(name: 'Acme Corp') }

  describe 'Resource-level root key with root :receipt' do
    it 'uses custom singular root key for show' do
      invoice = Invoice.create!(customer:, number: 'INV-001')

      get "/api/v1/receipts/#{invoice.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('receipt')
      expect(json).not_to have_key('invoice')
      expect(json['receipt']['number']).to eq('INV-001')
    end

    it 'uses custom plural root key for index' do
      Invoice.create!(customer:, number: 'INV-001')

      get '/api/v1/receipts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('receipts')
      expect(json).not_to have_key('invoices')
    end
  end

  describe 'Root key consistency across resources' do
    it 'same model produces different root keys through different resources' do
      invoice = Invoice.create!(customer:, number: 'INV-001')

      get "/api/v1/invoices/#{invoice.id}"
      invoice_json = JSON.parse(response.body)

      get "/api/v1/receipts/#{invoice.id}"
      receipt_json = JSON.parse(response.body)

      expect(invoice_json).to have_key('invoice')
      expect(receipt_json).to have_key('receipt')
      expect(invoice_json['invoice']['id']).to eq(receipt_json['receipt']['id'])
    end

    it 'receipt serializes fewer attributes than invoice' do
      invoice = Invoice.create!(customer:, notes: 'Some notes', number: 'INV-001')

      get "/api/v1/invoices/#{invoice.id}"
      invoice_json = JSON.parse(response.body)

      get "/api/v1/receipts/#{invoice.id}"
      receipt_json = JSON.parse(response.body)

      expect(invoice_json['invoice']).to have_key('notes')
      expect(receipt_json['receipt']).not_to have_key('notes')
      expect(receipt_json['receipt']).to have_key('id')
      expect(receipt_json['receipt']).to have_key('number')
    end
  end
end
