# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sorting', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:invoice2) { Invoice.create!(customer: customer1, due_on: 2.days.from_now, number: 'INV-002', status: :sent) }
  let!(:invoice3) { Invoice.create!(customer: customer1, due_on: 1.day.from_now, number: 'INV-003', status: :paid) }

  let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
  let!(:item2) { Item.create!(description: 'Software license', invoice: invoice2, quantity: 1, unit_price: 500.00) }
  let!(:item3) { Item.create!(description: 'Support contract', invoice: invoice3, quantity: 1, unit_price: 200.00) }

  describe 'GET /api/v1/invoices' do
    it 'sorts ascending by number' do
      get '/api/v1/invoices', params: { sort: { number: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to eq(%w[INV-001 INV-002 INV-003])
    end

    it 'sorts descending by number' do
      get '/api/v1/invoices', params: { sort: { number: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to eq(%w[INV-003 INV-002 INV-001])
    end

    it 'sorts by multiple fields' do
      get '/api/v1/invoices', params: { sort: { number: 'desc', status: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(3)
    end

    it 'sorts by created_at descending' do
      get '/api/v1/invoices', params: { sort: { created_at: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to eq(%w[INV-003 INV-002 INV-001])
    end

    it 'defaults to id ascending when no sort specified' do
      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      ids = json['invoices'].map { |inv| inv['id'] }
      expect(ids).to eq(ids.sort)
    end

    it 'returns error for unknown sort field' do
      get '/api/v1/invoices', params: { sort: { nonexistent: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      issue = json['issues'].find { |i| i['code'] == 'field_unknown' }
      expect(issue).to be_present
    end

    context 'with filtering' do
      it 'sorts filtered results' do
        get '/api/v1/invoices',
            params: {
              filter: { status: { eq: 'draft' } },
              sort: { number: 'desc' },
            }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(1)
        expect(json['invoices'][0]['number']).to eq('INV-001')
      end
    end

    context 'with pagination' do
      it 'preserves sort order across pages' do
        get '/api/v1/invoices',
            params: {
              page: { number: 1, size: 2 },
              sort: { number: 'asc' },
            }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['invoices'].length).to eq(2)
        numbers = json['invoices'].map { |inv| inv['number'] }
        expect(numbers).to eq(%w[INV-001 INV-002])
      end
    end
  end

  describe 'GET /api/v1/items' do
    it 'sorts by association field' do
      get '/api/v1/items', params: { sort: { invoice: { number: 'asc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      descriptions = json['items'].map { |item| item['description'] }
      expect(descriptions).to eq(['Consulting hours', 'Software license', 'Support contract'])
    end
  end
end
