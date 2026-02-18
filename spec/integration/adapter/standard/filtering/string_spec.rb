# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'String filtering', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:invoice2) do
    Invoice.create!(customer: customer1, due_on: 2.days.from_now, notes: 'Rush delivery', number: 'INV-002', status: :sent)
  end
  let!(:invoice3) { Invoice.create!(customer: customer1, due_on: 1.day.from_now, number: 'INV-003', status: :paid) }

  describe 'GET /api/v1/invoices' do
    context 'with eq operator' do
      it 'filters by exact match' do
        get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-001' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-001')
      end
    end

    context 'with contains operator' do
      it 'filters by substring' do
        get '/api/v1/invoices', params: { filter: { number: { contains: 'INV' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(3)
      end
    end

    context 'with starts_with operator' do
      it 'filters by prefix' do
        get '/api/v1/invoices', params: { filter: { number: { starts_with: 'INV-00' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(3)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-002', 'INV-003')
      end
    end

    context 'with ends_with operator' do
      it 'filters by suffix' do
        get '/api/v1/invoices', params: { filter: { number: { ends_with: '001' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-001')
      end
    end

    context 'with in operator' do
      it 'filters by multiple values' do
        get '/api/v1/invoices', params: { filter: { number: { in: %w[INV-001 INV-003] } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end

    context 'with null operator' do
      it 'filters by null true' do
        get '/api/v1/invoices', params: { filter: { notes: { null: true } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end

      it 'filters by null false' do
        get '/api/v1/invoices', params: { filter: { notes: { null: false } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-002')
      end
    end

    context 'when no records match' do
      it 'returns empty array when no matches found' do
        get '/api/v1/invoices', params: { filter: { number: { eq: 'INV-999' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices']).to eq([])
      end
    end
  end
end
