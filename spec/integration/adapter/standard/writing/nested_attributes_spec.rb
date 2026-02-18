# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested attributes', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }

  describe 'POST /api/v1/invoices' do
    it 'creates the invoice with nested items' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer1.id,
               items: [
                 { OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 10, unit_price: 150.00 },
                 { OP: 'create', description: 'Software license', invoice_id: 0, quantity: 1, unit_price: 500.00 },
               ],
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:created)
      created_invoice = Invoice.last
      expect(created_invoice.items.count).to eq(2)
      expect(created_invoice.items.pluck(:description)).to contain_exactly('Consulting hours', 'Software license')
    end
  end

  describe 'PATCH /api/v1/invoices/:id' do
    let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001') }
    let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
    let!(:item2) { Item.create!(description: 'Software license', invoice: invoice1, quantity: 1, unit_price: 500.00) }

    it 'updates existing nested item' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: {
              invoice: {
                items: [
                  { description: 'Updated consulting', id: item1.id, invoice_id: invoice1.id, quantity: 20 },
                ],
              },
            }

      expect(response).to have_http_status(:ok)
      item1.reload
      expect(item1.description).to eq('Updated consulting')
      expect(item1.quantity).to eq(20)
    end

    it 'deletes nested item with OP delete' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: {
              invoice: {
                items: [
                  { OP: 'delete', id: item1.id },
                ],
              },
            }

      expect(response).to have_http_status(:ok)
      invoice1.reload
      expect(invoice1.items.count).to eq(1)
      expect(Item.find_by(id: item1.id)).to be_nil
    end

    it 'handles mixed operations in single request' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: {
              invoice: {
                items: [
                  { description: 'Updated consulting', id: item1.id, invoice_id: invoice1.id, quantity: 20 },
                  { OP: 'delete', id: item2.id },
                  { OP: 'create',
                    description: 'Support contract',
                    invoice_id: invoice1.id,
                    quantity: 1,
                    unit_price: 200.00 },
                ],
              },
            }

      expect(response).to have_http_status(:ok)
      invoice1.reload
      expect(invoice1.items.count).to eq(2)
      expect(Item.find_by(id: item2.id)).to be_nil
      item1.reload
      expect(item1.description).to eq('Updated consulting')
    end
  end

  describe 'deep nesting' do
    it 'creates the invoice with items and adjustments' do
      post '/api/v1/invoices',
           as: :json,
           params: {
             invoice: {
               customer_id: customer1.id,
               items: [
                 {
                   OP: 'create',
                   adjustments: [
                     { OP: 'create', amount: -150.00, description: 'Discount 10%' },
                     { OP: 'create', amount: 50.00, description: 'Rush fee' },
                   ],
                   description: 'Consulting hours',
                   invoice_id: 0,
                   quantity: 10,
                   unit_price: 150.00,
                 },
               ],
               number: 'INV-001',
             },
           }

      expect(response).to have_http_status(:created)
      expect(Item.count).to eq(1)
      expect(Adjustment.count).to eq(2)
      expect(Item.last.adjustments.pluck(:description)).to contain_exactly('Discount 10%', 'Rush fee')
    end
  end
end
