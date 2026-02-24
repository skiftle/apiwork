# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Temporal filtering', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer, due_on: '2026-03-01', number: 'INV-001', status: :draft) }
  let!(:invoice2) do
    Invoice.create!(customer: customer, due_on: '2026-03-15', notes: 'Rush delivery', number: 'INV-002', status: :sent)
  end
  let!(:invoice3) { Invoice.create!(customer: customer, due_on: '2026-03-31', number: 'INV-003', status: :paid) }

  describe 'GET /api/v1/invoices' do
    context 'with date eq operator' do
      it 'filters by exact date' do
        get '/api/v1/invoices', params: { filter: { due_on: { eq: '2026-03-01' } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(1)
        expect(body['invoices'][0]['number']).to eq('INV-001')
      end
    end

    context 'with date gt operator' do
      it 'filters by date greater than' do
        get '/api/v1/invoices', params: { filter: { due_on: { gt: '2026-03-15' } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(1)
        expect(body['invoices'][0]['number']).to eq('INV-003')
      end
    end

    context 'with date gte operator' do
      it 'filters by date greater than or equal' do
        get '/api/v1/invoices', params: { filter: { due_on: { gte: '2026-03-15' } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-002', 'INV-003')
      end
    end

    context 'with date lt operator' do
      it 'filters by date less than' do
        get '/api/v1/invoices', params: { filter: { due_on: { lt: '2026-03-15' } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(1)
        expect(body['invoices'][0]['number']).to eq('INV-001')
      end
    end

    context 'with date lte operator' do
      it 'filters by date less than or equal' do
        get '/api/v1/invoices', params: { filter: { due_on: { lte: '2026-03-15' } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-002')
      end
    end

    context 'with date between operator' do
      it 'filters by date range' do
        get '/api/v1/invoices', params: { filter: { due_on: { between: { from: '2026-03-01', to: '2026-03-15' } } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-002')
      end
    end

    context 'with date in operator' do
      it 'filters by multiple dates' do
        get '/api/v1/invoices', params: { filter: { due_on: { in: %w[2026-03-01 2026-03-31] } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end

    context 'with date null operator' do
      it 'filters by null date' do
        Invoice.create!(customer: customer, number: 'INV-004', status: :draft)

        get '/api/v1/invoices', params: { filter: { due_on: { null: true } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(1)
        expect(body['invoices'][0]['number']).to eq('INV-004')
      end
    end
  end
end
