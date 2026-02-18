# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Numeric filtering', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
  let!(:item2) { Item.create!(description: 'Software license', invoice: invoice1, quantity: 1, unit_price: 500.00) }
  let!(:item3) { Item.create!(description: 'Support contract', invoice: invoice1, quantity: 5, unit_price: 200.00) }

  describe 'GET /api/v1/items' do
    context 'with eq operator' do
      it 'filters by exact value' do
        get '/api/v1/items', params: { filter: { quantity: { eq: 10 } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['description']).to eq('Consulting hours')
      end
    end

    context 'with gt operator' do
      it 'filters by greater than' do
        get '/api/v1/items', params: { filter: { quantity: { gt: 5 } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['description']).to eq('Consulting hours')
      end
    end

    context 'with gte operator' do
      it 'filters by greater than or equal' do
        get '/api/v1/items', params: { filter: { quantity: { gte: 5 } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(2)
        descriptions = body['items'].map { |item| item['description'] }
        expect(descriptions).to contain_exactly('Consulting hours', 'Support contract')
      end
    end

    context 'with lt operator' do
      it 'filters by less than' do
        get '/api/v1/items', params: { filter: { unit_price: { lt: 200.00 } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['description']).to eq('Consulting hours')
      end
    end

    context 'with lte operator' do
      it 'filters by less than or equal' do
        get '/api/v1/items', params: { filter: { unit_price: { lte: 200.00 } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(2)
        descriptions = body['items'].map { |item| item['description'] }
        expect(descriptions).to contain_exactly('Consulting hours', 'Support contract')
      end
    end

    context 'with between operator' do
      it 'filters by range' do
        get '/api/v1/items', params: { filter: { unit_price: { between: { from: 100.00, to: 250.00 } } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(2)
        descriptions = body['items'].map { |item| item['description'] }
        expect(descriptions).to contain_exactly('Consulting hours', 'Support contract')
      end
    end

    context 'with in operator' do
      it 'filters by multiple values' do
        get '/api/v1/items', params: { filter: { quantity: { in: [1, 10] } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(2)
        descriptions = body['items'].map { |item| item['description'] }
        expect(descriptions).to contain_exactly('Consulting hours', 'Software license')
      end
    end

    context 'with null operator on nullable decimal' do
      it 'filters by null true' do
        Item.create!(description: 'Free trial', invoice: invoice1, quantity: 1, unit_price: nil)

        get '/api/v1/items', params: { filter: { unit_price: { null: true } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['description']).to eq('Free trial')
      end
    end
  end
end
