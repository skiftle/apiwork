# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logical filtering', type: :request do
  let!(:customer) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(customer: customer, due_on: 3.days.from_now, number: 'INV-001', sent: true, status: :draft)
  end
  let!(:invoice2) do
    Invoice.create!(
      customer: customer,
      due_on: 2.days.from_now,
      notes: 'Rush delivery',
      number: 'INV-002',
      sent: false,
      status: :sent,
    )
  end
  let!(:invoice3) do
    Invoice.create!(customer: customer, due_on: 1.day.from_now, number: 'INV-003', sent: true, status: :paid)
  end

  describe 'GET /api/v1/invoices' do
    context 'with implicit AND' do
      it 'filters by multiple conditions' do
        get '/api/v1/invoices',
            params: {
              filter: {
                sent: { eq: true },
                status: { eq: 'paid' },
              },
            }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(1)
        expect(body['invoices'][0]['number']).to eq('INV-003')
      end
    end

    context 'with explicit OR' do
      it 'filters by either condition' do
        get '/api/v1/invoices?filter[OR][0][number][eq]=INV-001&filter[OR][1][number][eq]=INV-003'

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end

    context 'with NOT' do
      it 'filters by negated condition' do
        get '/api/v1/invoices', params: { filter: { NOT: { number: { eq: 'INV-001' } } } }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-002', 'INV-003')
      end
    end

    context 'with nested AND and OR' do
      it 'filters by combined logical operators' do
        get '/api/v1/invoices',
            params: {
              filter: {
                AND: [
                  { sent: { eq: true } },
                  { OR: [
                    { status: { eq: 'draft' } },
                    { status: { eq: 'paid' } },
                  ] },
                ],
              },
            }

        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['invoices'].length).to eq(2)
        numbers = body['invoices'].map { |inv| inv['number'] }
        expect(numbers).to contain_exactly('INV-001', 'INV-003')
      end
    end
  end
end
