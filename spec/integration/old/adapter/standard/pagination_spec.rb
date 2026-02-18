# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pagination', type: :request do
  let!(:customer1) { Customer.create!(name: 'Acme Corp') }

  before do
    25.times do |i|
      Invoice.create!(
        customer: customer1,
        due_on: (30 - i).days.from_now,
        number: "INV-#{format('%03d', i + 1)}",
        sent: i.even?,
        status: :draft,
      )
    end
  end

  describe 'offset pagination on invoices' do
    it 'returns first page' do
      get '/api/v1/invoices', params: { page: { number: 1, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(10)
      expect(json['pagination']['current']).to eq(1)
      expect(json['pagination']['total']).to eq(3)
      expect(json['pagination']['items']).to eq(25)
    end

    it 'returns second page' do
      get '/api/v1/invoices', params: { page: { number: 2, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(10)
      expect(json['pagination']['current']).to eq(2)
    end

    it 'returns last page with remaining items' do
      get '/api/v1/invoices', params: { page: { number: 3, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(5)
      expect(json['pagination']['current']).to eq(3)
      expect(json['pagination']['total']).to eq(3)
    end

    it 'returns empty array for page beyond total' do
      get '/api/v1/invoices', params: { page: { number: 100, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices']).to eq([])
    end

    it 'uses default page size when not specified' do
      get '/api/v1/invoices'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(20)
      expect(json['pagination']).to be_present
    end

    it 'rejects negative page number' do
      get '/api/v1/invoices', params: { page: { number: -1, size: 10 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues'].first['code']).to eq('number_too_small')
    end

    it 'enforces maximum page size' do
      get '/api/v1/invoices', params: { page: { number: 1, size: 10_000 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues'].first['code']).to eq('number_too_large')
    end

    it 'combines pagination with filtering' do
      get '/api/v1/invoices',
          params: {
            filter: { sent: { eq: true } },
            page: { number: 1, size: 5 },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['invoices'].length).to eq(5)
      json['invoices'].each do |invoice|
        expect(invoice['sent']).to be(true)
      end
      expect(json['pagination']['items']).to eq(13)
    end
  end

  describe 'cursor pagination on activities' do
    before do
      25.times do |i|
        Activity.create!(
          action: "action_#{format('%03d', i + 1)}",
          created_at: (25 - i).days.ago,
          read: i.even?,
          target_id: 1,
          target_type: 'Invoice',
        )
      end
    end

    it 'returns first page without cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(10)
      expect(json['pagination']['next']).to be_present
      expect(json['pagination']['prev']).to be_nil
    end

    it 'navigates forward with after cursor' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)
      next_cursor = json['pagination']['next']
      first_page_ids = json['activities'].map { |a| a['id'] }

      get '/api/v1/activities', params: { page: { after: next_cursor, size: 10 } }

      json = JSON.parse(response.body)
      second_page_ids = json['activities'].map { |a| a['id'] }
      expect(second_page_ids).not_to include(*first_page_ids)
    end

    it 'returns null next cursor on last page' do
      get '/api/v1/activities', params: { page: { size: 10 } }
      json = JSON.parse(response.body)

      get '/api/v1/activities', params: { page: { after: json['pagination']['next'], size: 10 } }
      json = JSON.parse(response.body)

      get '/api/v1/activities', params: { page: { after: json['pagination']['next'], size: 10 } }

      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(5)
      expect(json['pagination']['next']).to be_nil
    end

    it 'combines cursor pagination with filtering' do
      get '/api/v1/activities',
          params: {
            filter: { read: { eq: true } },
            page: { size: 5 },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['activities'].length).to eq(5)
      json['activities'].each do |activity|
        expect(activity['read']).to be(true)
      end
    end
  end
end
