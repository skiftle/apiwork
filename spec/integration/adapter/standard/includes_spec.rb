# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Includes', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:invoice2) { Invoice.create!(customer: customer1, due_on: 2.days.from_now, number: 'INV-002', status: :sent) }
  let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
  let!(:item2) { Item.create!(description: 'Software license', invoice: invoice1, quantity: 1, unit_price: 500.00) }
  let!(:item3) { Item.create!(description: 'Support contract', invoice: invoice2, quantity: 1, unit_price: 200.00) }
  let!(:adjustment1) { Adjustment.create!(amount: -150.00, description: 'Discount 10%', item: item1) }
  let!(:attachment1) { Attachment.create!(filename: 'document.pdf', invoice: invoice1) }
  let!(:attachment2) { Attachment.create!(filename: 'image.png', invoice: invoice1) }

  describe 'GET /api/v1/invoices' do
    context 'without include parameter' do
      it 'omits optional associations by default' do
        get '/api/v1/invoices'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].first.keys).not_to include('items')
      end
    end

    context 'with include parameter' do
      it 'includes optional association when requested' do
        get '/api/v1/invoices', params: { include: { items: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        first_invoice = json['invoices'].find { |inv| inv['number'] == 'INV-001' }
        expect(first_invoice['items'].length).to eq(2)
      end

      it 'includes multiple associations when requested' do
        get '/api/v1/invoices', params: { include: { attachments: true, items: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        first_invoice = json['invoices'].find { |inv| inv['number'] == 'INV-001' }
        expect(first_invoice['items'].length).to eq(2)
        expect(first_invoice['attachments'].length).to eq(2)
      end

      it 'includes nested associations' do
        get '/api/v1/invoices', params: { include: { items: { adjustments: true } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        first_invoice = json['invoices'].find { |inv| inv['number'] == 'INV-001' }
        expect(first_invoice['items'].length).to eq(2)
        first_item = first_invoice['items'].find { |item| item['description'] == 'Consulting hours' }
        expect(first_item['adjustments'].length).to eq(1)
      end
    end

    context 'with unknown include' do
      it 'returns error for unknown include' do
        get '/api/v1/invoices', params: { include: { nonexistent: true } }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        issue = json['issues'].find { |i| i['code'] == 'field_unknown' }
        expect(issue).to be_present
      end
    end
  end

  describe 'GET /api/v1/invoices/:id' do
    it 'includes optional association on show when requested' do
      get "/api/v1/invoices/#{invoice1.id}", params: { include: { items: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['items'].length).to eq(2)
    end

    it 'omits optional association on show when not requested' do
      get "/api/v1/invoices/#{invoice1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice'].keys).not_to include('items')
    end
  end
end
