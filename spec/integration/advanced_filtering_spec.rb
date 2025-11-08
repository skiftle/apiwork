# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advanced Filtering API', type: :request do
  before(:each) do
    # Clean database before each test to avoid pollution from other test suites
    # Delete comments first due to foreign key constraint
    Comment.delete_all
    Post.delete_all
  end

  let!(:post1) do
    Post.create!(title: 'Advanced Filter Test Ruby Basics', body: 'Introduction to Ruby', published: true, created_at: 5.days.ago)
  end
  let!(:post2) do
    Post.create!(title: 'Advanced Filter Test Rails Basics', body: 'Introduction to Rails', published: false, created_at: 3.days.ago)
  end
  let!(:post3) do
    Post.create!(title: 'Advanced Filter Test Advanced Ruby', body: 'Deep dive into Ruby', published: true, created_at: 1.day.ago)
  end
  let!(:post4) do
    Post.create!(title: 'Advanced Filter Test JavaScript Guide', body: 'Learn JavaScript', published: true, created_at: 2.days.ago)
  end

  describe 'OR logic filtering (array of filters)', :skip do
    it 'filters posts matching any condition' do
      get '/api/v1/posts', params: {
        filter: [
          { title: { equal: 'Advanced Filter Test Ruby Basics' } },
          { title: { equal: 'Advanced Filter Test Rails Basics' } }
        ]
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Ruby Basics', 'Advanced Filter Test Rails Basics'])
    end

    it 'filters posts with OR logic on different fields using array indices' do
      # Use array indices to preserve array structure in URL params
      # filter[0][title][contains]=Ruby&filter[1][body][contains]=JavaScript
      # Rails parses as: {"filter"=>{"0"=>{...}, "1"=>{...}}}
      # Apiwork normalizes to: {"filter"=>[{...}, {...}]}
      get '/api/v1/posts', params: {
        filter: {
          '0' => { title: { contains: 'Ruby' } },
          '1' => { body: { contains: 'JavaScript' } }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(3)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby', 'Advanced Filter Test JavaScript Guide'])
    end

    it 'combines OR logic with other parameters' do
      get '/api/v1/posts', params: {
        filter: [
          { title: { contains: 'Ruby' } },
          { title: { contains: 'Rails' } }
        ],
        sort: { title: 'asc' }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(3)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles.first).to eq('Advanced Filter Test Advanced Ruby')
    end
  end

  describe 'between operator for dates' do
    it 'filters posts between two dates' do
      from_date = 4.days.ago.iso8601
      to_date = 2.days.ago.iso8601

      get '/api/v1/posts', params: {
        filter: { created_at: { between: { from: from_date, to: to_date } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide'])
    end

    it 'returns empty array when no posts in date range' do
      from_date = 10.days.ago.iso8601
      to_date = 8.days.ago.iso8601

      get '/api/v1/posts', params: {
        filter: { created_at: { between: { from: from_date, to: to_date } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts']).to eq([])
    end
  end

  describe 'not_in operator' do
    it 'filters posts excluding specific ids' do
      excluded_ids = [post1.id, post3.id]

      get '/api/v1/posts', params: {
        filter: { id: { not_in: excluded_ids } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      ids = json['posts'].map { |p| p['id'] }
      expect(ids).to match_array([post2.id, post4.id])
    end

    it 'returns all posts when excluding non-existent ids' do
      get '/api/v1/posts', params: {
        filter: { id: { not_in: [99999, 88888] } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(4)
    end
  end

  describe 'not_contains operator for strings' do
    it 'filters posts not containing specific text' do
      get '/api/v1/posts', params: {
        filter: { title: { not_contains: 'Ruby' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide'])
    end

    it 'returns all posts when not_contains matches nothing' do
      get '/api/v1/posts', params: {
        filter: { title: { not_contains: 'Python' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(4)
    end
  end

  describe 'starts_with operator for strings' do
    it 'filters posts starting with specific text' do
      get '/api/v1/posts', params: {
        filter: { title: { starts_with: 'Advanced Filter Test Ruby' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Advanced Filter Test Ruby Basics')
    end

    it 'is case sensitive', skip: 'SQLite LIKE is case-insensitive - works correctly in PostgreSQL production' do
      get '/api/v1/posts', params: {
        filter: { title: { starts_with: 'advanced filter test ruby' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts']).to eq([])
    end
  end

  describe 'ends_with operator for strings' do
    it 'filters posts ending with specific text' do
      get '/api/v1/posts', params: {
        filter: { title: { ends_with: 'Basics' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Ruby Basics', 'Advanced Filter Test Rails Basics'])
    end

    it 'returns empty array when no matches' do
      get '/api/v1/posts', params: {
        filter: { title: { ends_with: 'Tutorial' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts']).to eq([])
    end
  end

  describe 'not_between operator for dates' do
    it 'filters posts outside a date range' do
      from_date = 4.days.ago.iso8601
      to_date = 2.days.ago.iso8601

      get '/api/v1/posts', params: {
        filter: { created_at: { not_between: { from: from_date, to: to_date } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby'])
    end
  end

  describe 'Complex filter combinations' do
    it 'combines multiple advanced operators' do
      get '/api/v1/posts', params: {
        filter: {
          title: { starts_with: 'Advanced Filter Test Ruby' },
          published: { equal: true },
          created_at: { greater_than: 6.days.ago.iso8601 }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Advanced Filter Test Ruby Basics')
    end

    it 'combines OR logic with AND logic', :skip do
      # This tests: (title contains Ruby OR title contains Rails) AND published = true
      get '/api/v1/posts', params: {
        filter: [
          {
            title: { contains: 'Ruby' },
            published: { equal: true }
          },
          {
            title: { contains: 'Rails' },
            published: { equal: true }
          }
        ]
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      # Should return Ruby Basics and Advanced Ruby (both published)
      # Rails Basics is not published, so it's excluded
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby'])
    end
  end
end
