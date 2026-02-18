# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Datetime filtering', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(
      created_at: '2026-03-01 10:00:00',
      customer: customer1,
      due_on: '2026-03-01',
      number: 'INV-001',
      status: :draft,
    )
  end
  let!(:invoice2) do
    Invoice.create!(
      created_at: '2026-03-15 14:30:00',
      customer: customer1,
      due_on: '2026-03-15',
      notes: 'Rush delivery',
      number: 'INV-002',
      status: :sent,
    )
  end
  let!(:invoice3) do
    Invoice.create!(
      created_at: '2026-03-31 09:00:00',
      customer: customer1,
      due_on: '2026-03-31',
      number: 'INV-003',
      status: :paid,
    )
  end

  describe 'GET /api/v1/invoices' do
    context 'with datetime eq operator' do
      it 'filters by exact datetime' do
        get '/api/v1/invoices', params: { filter: { created_at: { eq: '2026-03-15T14:30:00Z' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-002')
      end
    end

    context 'with datetime gt operator' do
      it 'filters by datetime greater than' do
        get '/api/v1/invoices', params: { filter: { created_at: { gt: '2026-03-15T14:30:00Z' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-003')
      end
    end

    context 'with datetime gte operator' do
      it 'filters by datetime greater than or equal' do
        get '/api/v1/invoices', params: { filter: { created_at: { gte: '2026-03-15T14:30:00Z' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-002', 'INV-003')
      end
    end

    context 'with datetime lt operator' do
      it 'filters by datetime less than' do
        get '/api/v1/invoices', params: { filter: { created_at: { lt: '2026-03-15T14:30:00Z' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-001')
      end
    end

    context 'with datetime lte operator' do
      it 'filters by datetime less than or equal' do
        get '/api/v1/invoices', params: { filter: { created_at: { lte: '2026-03-15T14:30:00Z' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-002')
      end
    end

    context 'with datetime between operator' do
      it 'filters by datetime range' do
        get '/api/v1/invoices',
            params: { filter: { created_at: { between: { from: '2026-03-01T00:00:00Z', to: '2026-03-15T23:59:59Z' } } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-002')
      end
    end

    context 'with datetime in operator' do
      it 'filters by multiple datetimes' do
        get '/api/v1/invoices',
            params: { filter: { created_at: { in: %w[2026-03-01T10:00:00Z 2026-03-31T09:00:00Z] } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end
  end
end
