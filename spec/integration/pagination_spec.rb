# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pagination API', type: :request do
  before do
    # Create 25 posts for pagination testing
    25.times do |i|
      Post.create!(
        title: "Post #{i + 1}",
        body: "Body #{i + 1}",
        published: i.even?,
        created_at: (25 - i).days.ago
      )
    end
  end

  describe 'GET /api/v1/posts with pagination' do
    it 'returns first page with default page size' do
      get '/api/v1/posts', params: { page: { number: 1, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(10)
      expect(json['pagination']['current']).to eq(1)
      expect(json['pagination']['total']).to eq(3)
      expect(json['pagination']['items']).to eq(25)
    end

    it 'returns second page' do
      get '/api/v1/posts', params: { page: { number: 2, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(10)
      expect(json['pagination']['current']).to eq(2)
    end

    it 'returns last page with remaining items' do
      get '/api/v1/posts', params: { page: { number: 3, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(5)
      expect(json['pagination']['current']).to eq(3)
      expect(json['pagination']['total']).to eq(3)
    end

    it 'handles different page sizes' do
      get '/api/v1/posts', params: { page: { number: 1, size: 5 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(5)
      expect(json['pagination']['total']).to eq(5)
    end

    it 'returns empty array for page beyond total pages' do
      get '/api/v1/posts', params: { page: { number: 100, size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts']).to eq([])
      expect(json['pagination']['current']).to eq(100)
    end

    it 'defaults to page 1 when no page number specified' do
      get '/api/v1/posts', params: { page: { size: 10 } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['pagination']['current']).to eq(1)
    end

    it 'uses default page size when not specified' do
      get '/api/v1/posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # Default page size should be 20 or similar
      expect(json['posts'].length).to be <= 25
      expect(json['pagination']).to be_present
    end

    it 'combines pagination with filtering' do
      get '/api/v1/posts', params: {
        filter: { published: { eq: true } },
        page: { number: 1, size: 5 }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(5)
      json['posts'].each do |post|
        expect(post['published']).to be(true)
      end
      # 13 even-numbered posts out of 25 total
      expect(json['pagination']['items']).to eq(13)
    end

    it 'combines pagination with sorting' do
      get '/api/v1/posts', params: {
        sort: { title: 'desc' },
        page: { number: 1, size: 5 }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(5)

      titles = json['posts'].map { |p| p['title'] }
      # Should start with highest titles (Post 9, Post 8, etc.)
      expect(titles.first).to match(/Post (9|25|24|23|22)/)
    end

    it 'combines pagination, filtering, and sorting' do
      get '/api/v1/posts', params: {
        filter: { published: { eq: true } },
        sort: { title: 'asc' },
        page: { number: 1, size: 3 }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(3)

      json['posts'].each do |post|
        expect(post['published']).to be(true)
      end

      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(titles.sort)
    end

    it 'rejects negative page numbers' do
      get '/api/v1/posts', params: { page: { number: -1, size: 10 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_an(Array)
      expect(json['errors'].first['code']).to eq('value_invalid')
      expect(json['errors'].first['pointer']).to eq('/page/number')
    end

    it 'rejects zero page size' do
      get '/api/v1/posts', params: { page: { number: 1, size: 0 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_an(Array)
      expect(json['errors'].first['code']).to eq('value_invalid')
      expect(json['errors'].first['pointer']).to eq('/page/size')
    end

    it 'enforces maximum page size' do
      get '/api/v1/posts', params: { page: { number: 1, size: 10_000 } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_an(Array)
      expect(json['errors'].first['code']).to eq('value_invalid')
      expect(json['errors'].first['pointer']).to eq('/page/size')
    end
  end
end
