# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Includes', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:invoice2) { Invoice.create!(customer: customer, due_on: 2.days.from_now, number: 'INV-002', status: :sent) }
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
        body = response.parsed_body
        expect(body['invoices'].first.keys).not_to include('items')
      end
    end

    context 'with include parameter' do
      it 'includes optional association when requested' do
        get '/api/v1/invoices', params: { include: { items: true } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        first_invoice = body['invoices'].find { |invoice| invoice['number'] == 'INV-001' }
        expect(first_invoice['items'].length).to eq(2)
      end

      it 'includes multiple associations when requested' do
        get '/api/v1/invoices', params: { include: { attachments: true, items: true } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        first_invoice = body['invoices'].find { |invoice| invoice['number'] == 'INV-001' }
        expect(first_invoice['items'].length).to eq(2)
        expect(first_invoice['attachments'].length).to eq(2)
      end

      it 'includes nested associations' do
        get '/api/v1/invoices', params: { include: { items: { adjustments: true } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        first_invoice = body['invoices'].find { |invoice| invoice['number'] == 'INV-001' }
        expect(first_invoice['items'].length).to eq(2)
        first_item = first_invoice['items'].find { |item| item['description'] == 'Consulting hours' }
        expect(first_item['adjustments'].length).to eq(1)
      end
    end

    context 'with unknown include' do
      it 'returns error for unknown include' do
        get '/api/v1/invoices', params: { include: { nonexistent: true } }

        expect(response).to have_http_status(:bad_request)
        body = response.parsed_body
        issue = body['issues'].find { |issue| issue['code'] == 'field_unknown' }
        expect(issue['code']).to eq('field_unknown')
      end
    end
  end

  describe 'GET /api/v1/invoices/:id' do
    it 'includes optional association on show when requested' do
      get "/api/v1/invoices/#{invoice1.id}", params: { include: { items: true } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoice']['items'].length).to eq(2)
    end

    it 'omits optional association on show when not requested' do
      get "/api/v1/invoices/#{invoice1.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoice'].keys).not_to include('items')
    end
  end

  describe 'POST /api/v1/invoices with include' do
    it 'includes items on create response' do
      post '/api/v1/invoices?include[items]=true',
           headers: { 'CONTENT_TYPE' => 'application/json' },
           params: {
             invoice: {
               customer_id: customer.id,
               number: 'INV-NEW',
             },
           }.to_json

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['invoice']).to have_key('items')
      expect(body['invoice']['items']).to eq([])
    end
  end

  describe 'PATCH /api/v1/invoices/:id with include' do
    it 'includes items on update response' do
      patch "/api/v1/invoices/#{invoice1.id}?include[items]=true",
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: { invoice: { number: 'INV-UPDATED' } }.to_json

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoice']['number']).to eq('INV-UPDATED')
      expect(body['invoice']['items'].length).to eq(2)
    end

    it 'omits items when not requested on update' do
      patch "/api/v1/invoices/#{invoice2.id}",
            as: :json,
            params: { invoice: { number: 'INV-CHANGED' } }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoice']['number']).to eq('INV-CHANGED')
      expect(body['invoice'].keys).not_to include('items')
    end
  end

  describe 'GET /api/v1/invoices with include and filtering' do
    it 'includes items combined with filtering' do
      get '/api/v1/invoices',
          params: {
            filter: { number: { eq: 'INV-001' } },
            include: { items: true },
          }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices'].length).to eq(1)
      expect(body['invoices'][0]['items'].length).to eq(2)
    end

    it 'includes items combined with sorting' do
      get '/api/v1/invoices',
          params: {
            include: { items: true },
            sort: { number: 'desc' },
          }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['invoices'][0]['number']).to eq('INV-002')
      expect(body['invoices'][0]['items'].length).to eq(1)
    end
  end
end
