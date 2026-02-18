# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adapter nested attributes', type: :request do
  let!(:customer1) { PersonCustomer.create!(email: 'BILLING@ACME.COM', name: 'Acme Corp') }

  describe 'creating with nested has_many' do
    it 'creates invoice with nested items' do
      invoice_params = {
        invoice: {
          customer_id: customer1.id,
          items: [
            { OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 10, unit_price: 150.00 },
            { OP: 'create', description: 'Travel expenses', invoice_id: 0, quantity: 1, unit_price: 500.00 },
          ],
          number: 'INV-001',
        },
      }

      post '/api/v1/invoices', as: :json, params: invoice_params

      expect(response).to have_http_status(:created)

      created_invoice = Invoice.last
      expect(created_invoice.items.count).to eq(2)
      expect(created_invoice.items.pluck(:description)).to contain_exactly('Consulting hours', 'Travel expenses')
    end

    it 'creates invoice without nested items key' do
      post '/api/v1/invoices',
           as: :json,
           params: { invoice: { customer_id: customer1.id, number: 'INV-001' } }

      expect(response).to have_http_status(:created)

      created_invoice = Invoice.last
      expect(created_invoice.items.count).to eq(0)
    end
  end

  describe 'creating with deep nesting' do
    it 'creates invoice with items and adjustments' do
      invoice_params = {
        invoice: {
          customer_id: customer1.id,
          items: [
            {
              OP: 'create',
              adjustments: [
                { OP: 'create', amount: -10.00, description: 'Discount' },
                { OP: 'create', amount: 5.00, description: 'Rush fee' },
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

      post '/api/v1/invoices', as: :json, params: invoice_params

      expect(response).to have_http_status(:created)
      expect(Item.count).to eq(1)
      expect(Adjustment.count).to eq(2)

      created_item = Item.last
      expect(created_item.adjustments.pluck(:description)).to contain_exactly('Discount', 'Rush fee')
    end
  end

  describe 'updating with nested has_many' do
    let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001') }
    let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150) }
    let!(:item2) { Item.create!(description: 'Travel expenses', invoice: invoice1, quantity: 1, unit_price: 500) }

    it 'updates existing items and adds new ones' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: {
              invoice: {
                items: [
                  { description: 'Updated consulting', id: item1.id, invoice_id: invoice1.id, quantity: 20 },
                  { OP: 'create', description: 'New line item', invoice_id: invoice1.id, quantity: 5, unit_price: 75.00 },
                ],
              },
            }

      expect(response).to have_http_status(:ok)

      invoice1.reload
      expect(invoice1.items.count).to eq(3)

      item1.reload
      expect(item1.description).to eq('Updated consulting')
      expect(item1.quantity).to eq(20)
    end

    it 'destroys items with OP delete' do
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
      expect(invoice1.items.first.id).to eq(item2.id)
      expect(Item.find_by(id: item1.id)).to be_nil
    end
  end

  describe 'deep nested destroy' do
    let!(:invoice1) { Invoice.create!(customer: customer1, number: 'INV-001') }
    let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150) }
    let!(:adjustment1) { Adjustment.create!(amount: 10, description: 'Discount', item: item1) }

    it 'destroys adjustments with OP delete' do
      patch "/api/v1/invoices/#{invoice1.id}",
            as: :json,
            params: {
              invoice: {
                items: [
                  {
                    OP: 'update',
                    adjustments: [{ OP: 'delete', id: adjustment1.id }],
                    description: 'Consulting hours',
                    id: item1.id,
                    invoice_id: invoice1.id,
                    quantity: 10,
                  },
                ],
              },
            }

      expect(response).to have_http_status(:ok)
      expect(Adjustment.find_by(id: adjustment1.id)).to be_nil
    end
  end

  describe 'parameter transformation' do
    it 'transforms items to items_attributes internally' do
      expect do
        post '/api/v1/invoices',
             as: :json,
             params: {
               invoice: {
                 customer_id: customer1.id,
                 items: [{ OP: 'create', description: 'Consulting hours', invoice_id: 0, quantity: 1, unit_price: 100.00 }],
                 number: 'INV-001',
               },
             }
      end.to change(Item, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end
end
