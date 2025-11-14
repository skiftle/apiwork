# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advanced Filtering API', type: :request do
  let!(:post1) do
    Post.create!(title: 'Advanced Filter Test Ruby Basics', body: 'Introduction to Ruby', published: true,
                 created_at: 5.days.ago)
  end
  let!(:post2) do
    Post.create!(title: 'Advanced Filter Test Rails Basics', body: 'Introduction to Rails', published: false,
                 created_at: 3.days.ago)
  end
  let!(:post3) do
    Post.create!(title: 'Advanced Filter Test Advanced Ruby', body: 'Deep dive into Ruby', published: true,
                 created_at: 1.day.ago)
  end
  let!(:post4) do
    Post.create!(title: 'Advanced Filter Test JavaScript Guide', body: 'Learn JavaScript', published: true,
                 created_at: 2.days.ago)
  end

  describe 'OR logic filtering (array of filters)' do
    it 'filters posts matching any condition' do
      get '/api/v1/posts', params: {
        filter: [
          { title: { eq: 'Advanced Filter Test Ruby Basics' } },
          { title: { eq: 'Advanced Filter Test Rails Basics' } }
        ]
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Rails Basics')
    end

    it 'filters posts with OR logic on different fields using _or operator' do
      # Use URL query string format for _or operator (to preserve array structure)
      get '/api/v1/posts?filter[_or][0][title][contains]=Ruby&filter[_or][1][body][contains]=JavaScript'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      puts "DEBUG: Found #{json['posts']&.length || 0} posts: #{json['posts']&.map { |p| "#{p['title']} (body: #{p['body']})" }}" if json['posts']&.length != 3
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(3)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby',
                                        'Advanced Filter Test JavaScript Guide')
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
      expect(json['ok']).to be(true)
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
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide')
    end

    it 'returns empty array when no posts in date range' do
      from_date = 10.days.ago.iso8601
      to_date = 8.days.ago.iso8601

      get '/api/v1/posts', params: {
        filter: { created_at: { between: { from: from_date, to: to_date } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts']).to eq([])
    end
  end

  describe '_not operator with :in' do
    it 'filters posts excluding specific ids using _not' do
      excluded_ids = [post1.id, post3.id]

      get '/api/v1/posts', params: {
        filter: { _not: { id: { in: excluded_ids } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      ids = json['posts'].map { |p| p['id'] }
      expect(ids).to contain_exactly(post2.id, post4.id)
    end

    it 'returns all posts when excluding non-existent ids' do
      get '/api/v1/posts', params: {
        filter: { _not: { id: { in: [99_999, 88_888] } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(4)
    end
  end

  describe '_not operator with :contains' do
    it 'filters posts not containing specific text using _not' do
      get '/api/v1/posts', params: {
        filter: { _not: { title: { contains: 'Ruby' } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide')
    end

    it 'returns all posts when _not + contains matches nothing' do
      get '/api/v1/posts', params: {
        filter: { _not: { title: { contains: 'Python' } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
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
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Advanced Filter Test Ruby Basics')
    end

    it 'is case sensitive', skip: 'SQLite LIKE is case-insensitive - works correctly in PostgreSQL production' do
      get '/api/v1/posts', params: {
        filter: { title: { starts_with: 'advanced filter test ruby' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
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
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Rails Basics')
    end

    it 'returns empty array when no matches' do
      get '/api/v1/posts', params: {
        filter: { title: { ends_with: 'Tutorial' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts']).to eq([])
    end
  end

  describe '_not operator with :between' do
    it 'filters posts outside a date range using _not' do
      from_date = 4.days.ago.iso8601
      to_date = 2.days.ago.iso8601

      get '/api/v1/posts', params: {
        filter: { _not: { created_at: { between: { from: from_date, to: to_date } } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby')
    end
  end

  describe 'Complex filter combinations' do
    it 'combines multiple advanced operators' do
      get '/api/v1/posts', params: {
        filter: {
          title: { starts_with: 'Advanced Filter Test Ruby' },
          published: { eq: true },
          created_at: { gt: 6.days.ago.iso8601 }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Advanced Filter Test Ruby Basics')
    end

    it 'combines OR logic with AND logic' do
      # This tests: (title contains Ruby OR title contains Rails) AND published = true
      get '/api/v1/posts', params: {
        filter: [
          {
            title: { contains: 'Ruby' },
            published: { eq: true }
          },
          {
            title: { contains: 'Rails' },
            published: { eq: true }
          }
        ]
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to be(true)
      # Should return Ruby Basics and Advanced Ruby (both published)
      # Rails Basics is not published, so it's excluded
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby')
    end
  end

  describe 'Logical operators (_or, _and, _not)' do
    describe '_or operator' do
      it 'filters posts matching any condition using _or' do
        get '/api/v1/posts', params: {
          filter: {
            _or: [
              { title: { contains: 'Ruby Basics' } },
              { title: { contains: 'Rails' } }
            ]
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Rails Basics')
      end

      it 'combines _or with other filters (implicit AND)' do
        # This tests: published = true AND (title contains Ruby OR title contains JavaScript)
        get '/api/v1/posts', params: {
          filter: {
            published: { eq: true },
            _or: [
              { title: { contains: 'Ruby' } },
              { title: { contains: 'JavaScript' } }
            ]
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        # Should return Ruby Basics, Advanced Ruby, and JavaScript Guide (all published)
        expect(json['posts'].length).to eq(3)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby',
                                          'Advanced Filter Test JavaScript Guide')
      end
    end

    describe '_and operator' do
      it 'explicitly combines conditions with _and' do
        get '/api/v1/posts', params: {
          filter: {
            _and: [
              { published: { eq: true } },
              { title: { contains: 'Ruby' } }
            ]
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby')
      end

      it 'chains multiple _and conditions' do
        get '/api/v1/posts', params: {
          filter: {
            _and: [
              { published: { eq: true } },
              { title: { contains: 'Ruby' } },
              { created_at: { lt: 2.days.ago.iso8601 } }
            ]
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['posts'].length).to eq(1)
        expect(json['posts'][0]['title']).to eq('Advanced Filter Test Ruby Basics')
      end
    end

    describe '_not operator' do
      it 'negates a single condition' do
        get '/api/v1/posts', params: {
          filter: {
            _not: { published: { eq: true } }
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['posts'].length).to eq(1)
        expect(json['posts'][0]['title']).to eq('Advanced Filter Test Rails Basics')
      end

      it 'combines _not with other filters' do
        # published = true AND NOT (title contains JavaScript)
        get '/api/v1/posts', params: {
          filter: {
            published: { eq: true },
            _not: { title: { contains: 'JavaScript' } }
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby')
      end

      it 'negates multiple conditions (De Morgan: NOT (A AND B))' do
        # NOT (published = true AND title contains Ruby)
        # Equivalent to: published != true OR title NOT contains Ruby
        get '/api/v1/posts', params: {
          filter: {
            _not: {
              published: { eq: true },
              title: { contains: 'Ruby' }
            }
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        # Should return: Rails Basics (not published), JavaScript Guide (doesn't contain Ruby)
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide')
      end
    end

    describe 'Recursive nesting' do
      it 'nests _or inside _and' do
        # published = true AND (title contains Ruby OR title contains Rails)
        get '/api/v1/posts', params: {
          filter: {
            _and: [
              { published: { eq: true } },
              {
                _or: [
                  { title: { contains: 'Ruby' } },
                  { title: { contains: 'Rails' } }
                ]
              }
            ]
          }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        # Rails Basics is not published, so it's excluded
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Ruby Basics', 'Advanced Filter Test Advanced Ruby')
      end

      it 'nests _not inside _or' do
        # title contains JavaScript OR NOT (published = true)
        # Use explicit array indexing to avoid Rails merging array elements
        get '/api/v1/posts', params: {
          'filter[_or][0][title][contains]' => 'JavaScript',
          'filter[_or][1][_not][published][eq]' => 'true'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        # Should return: Rails Basics (not published), JavaScript Guide (contains JavaScript)
        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide')
      end

      it 'handles complex nested logic: NOT ((A OR B) AND C)' do
        # NOT ((title contains Ruby OR title contains Rails) AND published = true)
        # By De Morgan: (title NOT contains Ruby AND title NOT contains Rails) OR published != true
        # Use explicit array indexing for nested arrays
        get '/api/v1/posts', params: {
          'filter[_not][_and][0][_or][0][title][contains]' => 'Ruby',
          'filter[_not][_and][0][_or][1][title][contains]' => 'Rails',
          'filter[_not][_and][1][published][eq]' => 'true'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to be(true)
        # Should return: Rails Basics (not published, contains Rails but fails the AND),
        #                JavaScript Guide (published but doesn't contain Ruby/Rails)

        expect(json['posts'].length).to eq(2)
        titles = json['posts'].map { |p| p['title'] }
        expect(titles).to contain_exactly('Advanced Filter Test Rails Basics', 'Advanced Filter Test JavaScript Guide')
      end
    end
  end
end
