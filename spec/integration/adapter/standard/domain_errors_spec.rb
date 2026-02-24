# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Domain errors', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }

  describe 'POST /api/v1/invoices' do
    it 'returns required for blank field' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      expect(body['layer']).to eq('domain')
      issue = body['issues'].find { |issue| issue['code'] == 'required' }
      expect(issue['detail']).to eq('Required')
      expect(issue['path']).to eq(%w[invoice number])
      expect(issue['pointer']).to eq('/invoice/number')
      expect(issue['meta']).to eq({})
    end

    it 'returns unique for duplicate value' do
      Invoice.create!(customer: customer, number: 'INV-001')

      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: 'INV-001' } }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'unique' }
      expect(issue['detail']).to eq('Already taken')
      expect(issue['path']).to eq(%w[invoice number])
      expect(issue['meta']).to eq({})
    end

    it 'returns min with meta for too short value' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: 'AB' } }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'min' }
      expect(issue['detail']).to eq('Too short')
      expect(issue['path']).to eq(%w[invoice number])
      expect(issue['meta']).to eq({ 'min' => 3 })
    end

    it 'returns max with meta for too long value' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: "INV-#{'A' * 17}" } }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'max' }
      expect(issue['detail']).to eq('Too long')
      expect(issue['path']).to eq(%w[invoice number])
      expect(issue['meta']).to eq({ 'max' => 20 })
    end

    it 'returns custom type for record-level error' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: 'BAD-001' } }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['path'] == %w[invoice] }
      expect(issue['code']).to eq('billing_format')
      expect(issue['detail']).to eq('Billing format')
      expect(issue['pointer']).to eq('/invoice')
    end

    it 'returns custom code for domain-specific validation' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer.id, number: 'BAD-001' } }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['path'] == %w[invoice number] }
      expect(issue['code']).to eq('billing_format')
      expect(issue['detail']).to eq('Billing format')
    end
  end

  describe 'POST /api/v1/invoices with nested items' do
    it 'returns error with indexed path for nested item' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               items: [
                 { OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 10, unit_price: 150.00 },
                 { OP: 'create', description: '', invoice_id: 0, quantity: 10, unit_price: 150.00 },
               ],
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'required' }
      expect(issue['path']).to eq(%w[invoice items 1 description])
      expect(issue['pointer']).to eq('/invoice/items/1/description')
    end

    it 'returns gt with meta for nested numericality error' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               items: [
                 { OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 0, unit_price: 150.00 },
               ],
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'gt' }
      expect(issue['detail']).to eq('Too small')
      expect(issue['path']).to eq(%w[invoice items 0 quantity])
      expect(issue['meta']).to eq({ 'gt' => 0 })
    end

    it 'returns lt with meta for nested value too large' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               items: [
                 { OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 10_000, unit_price: 150.00 },
               ],
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'lt' }
      expect(issue['detail']).to eq('Too large')
      expect(issue['path']).to eq(%w[invoice items 0 quantity])
      expect(issue['meta']).to eq({ 'lt' => 10_000 })
    end

    it 'returns gte with meta for nested value below minimum' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer.id,
               items: [
                 { OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 1, unit_price: -1.00 },
               ],
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'gte' }
      expect(issue['detail']).to eq('Too small')
      expect(issue['path']).to eq(%w[invoice items 0 unit_price])
      expect(issue['meta']).to eq({ 'gte' => 0 })
    end
  end

  describe 'POST /api/v1/customers' do
    it 'returns unique for duplicate customer name' do
      post '/api/v1/customers',
           as: :json,
           params: {
             customer: {
               email: 'billing2@acme.com',
               name: 'Acme Corp',
               type: 'company',
             },
           }

      expect(response).to have_http_status(:unprocessable_content)
      body = response.parsed_body
      issue = body['issues'].find { |issue| issue['code'] == 'unique' }
      expect(issue['detail']).to eq('Already taken')
      expect(issue['path']).to eq(%w[customer name])
    end
  end
end
