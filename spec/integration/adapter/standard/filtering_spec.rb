# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filtering', type: :request do
  let!(:customer1) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', sent: true, status: :draft)
  end
  let!(:invoice2) do
    Invoice.create!(customer: customer1, due_on: 7.days.from_now, number: 'INV-002', sent: false, status: :sent)
  end
  let!(:invoice3) do
    Invoice.create!(customer: customer1, due_on: 14.days.from_now, number: 'INV-003', sent: true, status: :paid)
  end

  describe 'GET /api/v1/invoices' do
    it 'filters by eq' do
      get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-001' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(1)
      expect(json['invoices'][0]['number']).to eq('INV-001')
    end

    it 'filters by contains' do
      get '/api/v1/invoices', params: { filter: { number: { contains: 'INV' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(3)
    end

    it 'filters by gt' do
      get '/api/v1/invoices', params: { filter: { due_on: { gt: 5.days.from_now.to_date.iso8601 } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(2)
    end

    it 'filters by lte' do
      get '/api/v1/invoices', params: { filter: { due_on: { lte: 7.days.from_now.to_date.iso8601 } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(2)
    end

    it 'filters by in' do
      get '/api/v1/invoices', params: { filter: { id: { in: [invoice1.id, invoice3.id] } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      ids = json['invoices'].map { |inv| inv['id'] }
      expect(ids).to contain_exactly(invoice1.id, invoice3.id)
    end

    it 'filters by NOT' do
      get '/api/v1/invoices', params: { filter: { NOT: { number: { eq: 'INV-001' } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(2)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to contain_exactly('INV-002', 'INV-003')
    end

    it 'filters by OR' do
      get '/api/v1/invoices?filter[OR][0][number][eq]=INV-001&filter[OR][1][number][eq]=INV-003'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(2)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to contain_exactly('INV-001', 'INV-003')
    end

    it 'filters by AND' do
      get '/api/v1/invoices',
          params: {
            filter: {
              AND: [
                { sent: { eq: true } },
                { status: { eq: 'draft' } },
              ],
            },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(1)
      expect(json['invoices'][0]['number']).to eq('INV-001')
    end

    it 'combines multiple filters with implicit AND' do
      get '/api/v1/invoices',
          params: {
            filter: {
              sent: { eq: true },
              status: { eq: 'paid' },
            },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(1)
      expect(json['invoices'][0]['number']).to eq('INV-003')
    end

    it 'returns empty array when no matches' do
      get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-999' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices']).to eq([])
    end

    it 'rejects unknown filter field' do
      get '/api/v1/invoices', params: { filter: { unknown_field: { eq: 'value' } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues']).not_to be_empty
    end

    it 'rejects invalid filter operator' do
      get '/api/v1/invoices', params: { filter: { number: { invalid_op: 'value' } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
    end
  end

  describe 'GET /api/v1/invoices with enum filter' do
    it 'filters by enum status' do
      get '/api/v1/invoices', params: { filter: { status: { eq: 'sent' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(1)
      expect(json['invoices'][0]['number']).to eq('INV-002')
    end
  end

  describe 'GET /api/v1/invoices with boolean filter' do
    it 'filters by boolean sent' do
      get '/api/v1/invoices', params: { filter: { sent: { eq: true } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(2)
      json['invoices'].each do |invoice|
        expect(invoice['sent']).to be(true)
      end
    end
  end

  describe 'unknown query params' do
    it 'rejects unknown query parameters on show' do
      get "/api/v1/invoices/#{invoice1.id}", params: { unknown_param: 'value' }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues'].first['code']).to eq('field_unknown')
    end
  end
end
