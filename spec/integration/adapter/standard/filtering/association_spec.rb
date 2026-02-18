# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Association filtering', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) { Invoice.create!(customer: customer1, due_on: 3.days.from_now, number: 'INV-001', status: :draft) }
  let!(:invoice2) do
    Invoice.create!(customer: customer1, due_on: 2.days.from_now, notes: 'Rush delivery', number: 'INV-002', status: :sent)
  end
  let!(:item1) { Item.create!(description: 'Consulting hours', invoice: invoice1, quantity: 10, unit_price: 150.00) }
  let!(:item2) { Item.create!(description: 'Software license', invoice: invoice1, quantity: 1, unit_price: 500.00) }
  let!(:item3) { Item.create!(description: 'Support contract', invoice: invoice2, quantity: 1, unit_price: 200.00) }

  describe 'GET /api/v1/items' do
    context 'with direct association filter' do
      it 'filters by association field' do
        get '/api/v1/items', params: { filter: { invoice: { number: { eq: 'INV-001' } } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(2)
        descriptions = body['items'].map { |item| item['description'] }
        expect(descriptions).to contain_exactly('Consulting hours', 'Software license')
      end
    end

    context 'with association filter on status' do
      it 'filters by association enum' do
        get '/api/v1/items', params: { filter: { invoice: { status: { eq: 'sent' } } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['description']).to eq('Support contract')
      end
    end

    context 'with multiple association filters' do
      it 'filters by multiple association fields' do
        get '/api/v1/items',
            params: {
              filter: {
                description: { eq: 'Consulting hours' },
                invoice: { number: { eq: 'INV-001' } },
              },
            }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['items'].length).to eq(1)
        expect(body['items'][0]['description']).to eq('Consulting hours')
      end
    end
  end
end
