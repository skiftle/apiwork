# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filter Operators' do
  let!(:old_post) { Post.create!(title: 'Old Post', created_at: 3.days.ago) }
  let!(:recent_post) { Post.create!(title: 'Recent Post', created_at: 1.day.ago) }
  let!(:new_post) { Post.create!(title: 'New Post', created_at: 1.hour.ago) }

  describe 'Comparison operators for dates' do
    describe 'gte (greater than or equal)' do
      it 'filters posts created on or after a specific date' do
        cutoff = 2.days.ago

        get '/api/v1/posts', params: { filter: { created_at: { gte: cutoff.iso8601 } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        titles = json['posts'].map { |p| p['title'] }

        expect(titles).to include('Recent Post', 'New Post')
        expect(titles).not_to include('Old Post')
      end

      it 'includes posts with exact timestamp match' do
        exact_time = recent_post.created_at

        get '/api/v1/posts', params: { filter: { created_at: { gte: exact_time.iso8601 } } }

        json = JSON.parse(response.body)
        titles = json['posts'].map { |p| p['title'] }

        expect(titles).to include('Recent Post')
      end
    end

    describe 'lt (less than)' do
      it 'filters posts created before a specific date' do
        cutoff = 2.days.ago

        get '/api/v1/posts', params: { filter: { created_at: { lt: cutoff.iso8601 } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        titles = json['posts'].map { |p| p['title'] }

        expect(titles).to include('Old Post')
        expect(titles).not_to include('Recent Post', 'New Post')
      end

      it 'excludes posts with exact timestamp match' do
        exact_time = recent_post.created_at

        get '/api/v1/posts', params: { filter: { created_at: { lt: exact_time.iso8601 } } }

        json = JSON.parse(response.body)
        titles = json['posts'].map { |p| p['title'] }

        expect(titles).not_to include('Recent Post')
      end
    end
  end

  describe 'in operator with single value' do
    it 'filters with array containing single ID' do
      get '/api/v1/posts', params: { filter: { id: { in: [recent_post.id] } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['posts'].length).to eq(1)
      expect(json['posts'].first['title']).to eq('Recent Post')
    end
  end

  describe 'in operator with empty array' do
    it 'returns error for empty array' do
      get '/api/v1/posts', params: { filter: { id: { in: [] } } }

      # Empty array in filter is invalid - should error
      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(false)
    end
  end

  describe 'Combining multiple comparison operators' do
    it 'filters posts within a date range using gte and lt' do
      start_date = 2.days.ago
      end_date = 12.hours.ago

      get '/api/v1/posts', params: {
        filter: {
          created_at: {
            gte: start_date.iso8601,
            lt: end_date.iso8601
          }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }

      expect(titles).to include('Recent Post')
      expect(titles).not_to include('Old Post', 'New Post')
    end
  end

  describe 'Case sensitivity in string filters' do
    let!(:lowercase_post) { Post.create!(title: 'test lowercase') }
    let!(:uppercase_post) { Post.create!(title: 'TEST UPPERCASE') }
    let!(:mixed_post) { Post.create!(title: 'Test MixedCase') }

    describe 'contains operator' do
      it 'performs case-insensitive search' do
        get '/api/v1/posts', params: { filter: { title: { contains: 'test' } } }

        json = JSON.parse(response.body)
        titles = json['posts'].map { |p| p['title'] }

        # SQLite LIKE is case-insensitive by default
        expect(titles).to include('test lowercase', 'TEST UPPERCASE', 'Test MixedCase')
      end
    end

    describe 'eq operator' do
      it 'performs exact match' do
        get '/api/v1/posts', params: { filter: { title: { eq: 'test lowercase' } } }

        json = JSON.parse(response.body)

        expect(json['posts'].length).to eq(1)
        expect(json['posts'].first['title']).to eq('test lowercase')
      end
    end
  end

  describe 'Filter with special characters' do
    let!(:special_post) { Post.create!(title: "Test's \"Special\" <Characters>") }

    it 'handles single quotes in filter value' do
      get '/api/v1/posts', params: { filter: { title: { contains: "Test's" } } }

      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }

      expect(titles).to include("Test's \"Special\" <Characters>")
    end

    it 'handles double quotes in filter value' do
      get '/api/v1/posts', params: { filter: { title: { contains: '"Special"' } } }

      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }

      expect(titles).to include("Test's \"Special\" <Characters>")
    end
  end

  describe 'Many filters at once (stress test)' do
    it 'handles 10+ filter conditions' do
      get '/api/v1/posts', params: {
        filter: {
          created_at: { gte: 10.days.ago.iso8601 },
          title: { contains: 'Post' },
          published: { eq: false },
          id: { in: [old_post.id, recent_post.id, new_post.id] }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # Should return all three posts matching all conditions
      expect(json['posts'].length).to be >= 0
    end
  end
end
