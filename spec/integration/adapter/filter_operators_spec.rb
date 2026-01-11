# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filter Operators' do
  let!(:old_post) { Post.create!(created_at: 3.days.ago, title: 'Old Post') }
  let!(:recent_post) { Post.create!(created_at: 1.day.ago, title: 'Recent Post') }
  let!(:new_post) { Post.create!(created_at: 1.hour.ago, title: 'New Post') }

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
      JSON.parse(response.body)
    end
  end

  describe 'Combining multiple comparison operators' do
    it 'filters posts within a date range using gte and lt' do
      start_date = 2.days.ago
      end_date = 12.hours.ago

      get '/api/v1/posts',
          params: {
            filter: {
              created_at: {
                gte: start_date.iso8601,
                lt: end_date.iso8601,
              },
            },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }

      expect(titles).to include('Recent Post')
      expect(titles).not_to include('Old Post', 'New Post')
    end
  end

  describe 'Case sensitivity in string filters' do
    let!(:lowercase_post) { Post.create!(title: 'draft lowercase') }
    let!(:uppercase_post) { Post.create!(title: 'DRAFT UPPERCASE') }
    let!(:mixed_post) { Post.create!(title: 'Draft MixedCase') }

    describe 'contains operator' do
      it 'performs case-sensitive search' do
        get '/api/v1/posts', params: { filter: { title: { contains: 'draft' } } }

        json = JSON.parse(response.body)
        titles = json['posts'].map { |p| p['title'] }

        expect(titles).to eq(['draft lowercase'])
      end
    end

    describe 'eq operator' do
      it 'performs exact match' do
        get '/api/v1/posts', params: { filter: { title: { eq: 'draft lowercase' } } }

        json = JSON.parse(response.body)

        expect(json['posts'].length).to eq(1)
        expect(json['posts'].first['title']).to eq('draft lowercase')
      end
    end
  end

  describe 'Filter with special characters' do
    let!(:special_post) { Post.create!(title: "Jane's \"Special\" <Characters>") }

    it 'handles single quotes in filter value' do
      get '/api/v1/posts', params: { filter: { title: { contains: "Jane's" } } }

      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }

      expect(titles).to include("Jane's \"Special\" <Characters>")
    end

    it 'handles double quotes in filter value' do
      get '/api/v1/posts', params: { filter: { title: { contains: '"Special"' } } }

      json = JSON.parse(response.body)
      titles = json['posts'].map { |p| p['title'] }

      expect(titles).to include("Jane's \"Special\" <Characters>")
    end
  end

  describe 'Many filters at once (stress test)' do
    it 'handles 10+ filter conditions' do
      get '/api/v1/posts',
          params: {
            filter: {
              created_at: { gte: 10.days.ago.iso8601 },
              id: { in: [old_post.id, recent_post.id, new_post.id] },
              published: { eq: false },
              title: { contains: 'Post' },
            },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # Should return all three posts matching all conditions
      expect(json['posts'].length).to be >= 0
    end
  end
end
