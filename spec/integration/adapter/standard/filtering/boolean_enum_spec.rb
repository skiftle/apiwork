# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Boolean and enum filtering', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', sent: true, status: :draft)
  end
  let!(:invoice2) do
    Invoice.create!(
      customer: customer1,
      due_on: 2.days.from_now,
      notes: 'Rush delivery',
      number: 'INV-002',
      sent: false,
      status: :sent,
    )
  end
  let!(:invoice3) do
    Invoice.create!(customer: customer1, due_on: 1.day.from_now, number: 'INV-003', sent: true, status: :paid)
  end

  describe 'GET /api/v1/invoices' do
    context 'with boolean eq true' do
      it 'filters by boolean true' do
        get '/api/v1/invoices', params: { filter: { sent: { eq: true } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end

    context 'with boolean eq false' do
      it 'filters by boolean false' do
        get '/api/v1/invoices', params: { filter: { sent: { eq: false } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-002')
      end
    end

    context 'with boolean null operator' do
      it 'filters by null boolean' do
        Invoice.create!(customer: customer1, number: 'INV-004', sent: nil, status: :draft)

        get '/api/v1/invoices', params: { filter: { sent: { null: true } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-004')
      end
    end

    context 'with enum eq operator' do
      it 'filters by enum value' do
        get '/api/v1/invoices', params: { filter: { status: { eq: 'sent' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-002')
      end
    end

    context 'with enum in operator' do
      it 'filters by multiple enum values' do
        get '/api/v1/invoices', params: { filter: { status: { in: %w[draft paid] } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end

    context 'with invalid enum value' do
      it 'returns empty array when no matches found' do
        get '/api/v1/invoices', params: { filter: { status: { eq: 'nonexistent' } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices']).to eq([])
      end
    end
  end
end
