# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sorting', type: :request do
  let!(:customer1) { Customer.create!(name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(
      created_at: 3.days.ago,
      customer: customer1,
      due_on: 10.days.from_now,
      number: 'INV-001',
      status: :draft,
    )
  end
  let!(:invoice2) do
    Invoice.create!(
      created_at: 2.days.ago,
      customer: customer1,
      due_on: 5.days.from_now,
      number: 'INV-002',
      status: :sent,
    )
  end
  let!(:invoice3) do
    Invoice.create!(
      created_at: 1.day.ago,
      customer: customer1,
      due_on: 20.days.from_now,
      number: 'INV-003',
      status: :paid,
    )
  end

  describe 'GET /api/v1/invoices with sorting' do
    it 'sorts by number ascending' do
      get '/api/v1/invoices', params: { sort: { number: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to eq(%w[INV-001 INV-002 INV-003])
    end

    it 'sorts by number descending' do
      get '/api/v1/invoices', params: { sort: { number: 'desc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to eq(%w[INV-003 INV-002 INV-001])
    end

    it 'sorts by due_on ascending' do
      get '/api/v1/invoices', params: { sort: { due_on: 'asc' } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      numbers = json['invoices'].map { |inv| inv['number'] }
      expect(numbers).to eq(%w[INV-002 INV-001 INV-003])
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

    it 'rejects unknown sort field' do
      get '/api/v1/invoices', params: { sort: { unknown_field: 'asc' } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_an(Array)
      expect(json['issues']).not_to be_empty
    end

    it 'combines sorting with filtering' do
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

  describe 'GET /api/v1/invoices with multi-field sort' do
    it 'sorts by multiple fields' do
      get '/api/v1/invoices',
          params: {
            sort: { number: 'desc', sent: 'asc' },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(3)
    end

    it 'combines sorting with pagination' do
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
