# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Includes', type: :request do
  let!(:customer1) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(customer: customer1, number: 'INV-001', status: :draft).tap do |invoice|
      invoice.items.create!(description: 'Consulting hours', quantity: 2, unit_price: 150.0)
      invoice.items.create!(description: 'Software license', quantity: 1, unit_price: 500.0)
    end
  end
  let!(:invoice2) do
    Invoice.create!(customer: customer1, number: 'INV-002', status: :sent).tap do |invoice|
      invoice.items.create!(description: 'Support contract', quantity: 1, unit_price: 300.0)
    end
  end

  describe 'GET /api/v1/invoices' do
    context 'without include parameter' do
      it 'does not include items' do
        get '/api/v1/invoices'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].first.keys).not_to include('items')
      end
    end

    context 'with include parameter' do
      it 'includes items when requested' do
        get '/api/v1/invoices', params: { include: { items: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        first_invoice = json['invoices'].find { |inv| inv['number'] == 'INV-001' }
        expect(first_invoice['items']).to be_present
        expect(first_invoice['items'].length).to eq(2)
      end

      it 'includes items with filtering' do
        get '/api/v1/invoices',
            params: {
              filter: { number: { eq: 'INV-001' } },
              include: { items: true },
            }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['items']).to be_present
      end

      it 'includes items with sorting' do
        get '/api/v1/invoices',
            params: {
              include: { items: true },
              sort: { number: 'desc' },
            }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'][0]['number']).to eq('INV-002')
        expect(json['invoices'][0]['items']).to be_present
      end
    end
  end

  describe 'GET /api/v1/invoices/:id' do
    it 'includes items on show action' do
      get "/api/v1/invoices/#{invoice1.id}", params: { include: { items: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['items']).to be_present
      expect(json['invoice']['items'].length).to eq(2)
    end

    it 'does not include items when not requested' do
      get "/api/v1/invoices/#{invoice1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice'].keys).not_to include('items')
    end
  end

  describe 'POST /api/v1/invoices with include' do
    it 'includes items on create action' do
      post '/api/v1/invoices?include[items]=true',
           headers: { 'CONTENT_TYPE' => 'application/json' },
           params: {
             invoice: {
               customer_id: customer1.id,
               number: 'INV-NEW',
             },
           }.to_json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['invoice']).to have_key('items')
      expect(json['invoice']['items']).to eq([])
    end
  end

  describe 'PATCH /api/v1/invoices/:id with include' do
    it 'includes items on update action' do
      patch "/api/v1/invoices/#{invoice1.id}?include[items]=true",
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: { invoice: { number: 'INV-UPDATED' } }.to_json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['number']).to eq('INV-UPDATED')
      expect(json['invoice']['items']).to be_present
      expect(json['invoice']['items'].length).to eq(2)
    end

    it 'does not include items when not requested' do
      patch "/api/v1/invoices/#{invoice2.id}",
            as: :json,
            params: { invoice: { number: 'INV-CHANGED' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoice']['number']).to eq('INV-CHANGED')
      expect(json['invoice'].keys).not_to include('items')
    end
  end

  describe 'invalid includes' do
    it 'rejects unknown include parameters' do
      get '/api/v1/invoices', params: { include: { unknown_association: true } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_present
    end
  end
end
