# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Association Filtering API', type: :request do
  before(:each) do
    # Clean database before each test to avoid pollution from other test suites
    # Delete comments first due to foreign key constraint
    Comment.delete_all
    Post.delete_all
  end

  let!(:post1) do
    Post.create!(title: 'Ruby Tutorial', body: 'Learn Ruby', published: true, created_at: 3.days.ago)
  end
  let!(:post2) do
    Post.create!(title: 'Rails Guide', body: 'Learn Rails', published: false, created_at: 2.days.ago)
  end
  let!(:post3) do
    Post.create!(title: 'Advanced Ruby', body: 'Master Ruby', published: true, created_at: 1.day.ago)
  end

  let!(:comment1) do
    Comment.create!(post: post1, content: 'Great tutorial!', author: 'Alice', created_at: 2.days.ago)
  end
  let!(:comment2) do
    Comment.create!(post: post1, content: 'Very helpful', author: 'Bob', created_at: 1.day.ago)
  end
  let!(:comment3) do
    Comment.create!(post: post2, content: 'Needs more examples', author: 'Alice', created_at: 1.day.ago)
  end
  let!(:comment4) do
    Comment.create!(post: post3, content: 'Excellent content!', author: 'Charlie', created_at: 1.hour.ago)
  end

  describe 'GET /api/v1/posts with comment filters (has_many)' do
    it 'filters posts by comment author' do
      get '/api/v1/posts', params: { filter: { comments: { author: { equal: 'Alice' } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(2)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to match_array(['Ruby Tutorial', 'Rails Guide'])
    end

    it 'filters posts by comment content contains' do
      get '/api/v1/posts', params: { filter: { comments: { content: { contains: 'tutorial' } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Ruby Tutorial')
    end

    it 'filters posts by comment created_at' do
      get '/api/v1/posts', params: {
        filter: { comments: { created_at: { greater_than: 1.5.days.ago.iso8601 } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(3)
    end

    it 'combines post filters with comment filters (AND logic)' do
      get '/api/v1/posts', params: {
        filter: {
          published: { equal: true },
          comments: { author: { equal: 'Alice' } }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Ruby Tutorial')
    end

    it 'filters posts with multiple comment conditions' do
      get '/api/v1/posts', params: {
        filter: {
          comments: {
            author: { equal: 'Alice' },
            content: { contains: 'tutorial' }
          }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Ruby Tutorial')
    end

    it 'returns empty array when no posts match comment filter' do
      get '/api/v1/posts', params: { filter: { comments: { author: { equal: 'Nonexistent' } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts']).to eq([])
    end
  end

  describe 'GET /api/v1/comments with post filters (belongs_to)' do
    it 'filters comments by post title' do
      get '/api/v1/comments', params: { filter: { post: { title: { equal: 'Ruby Tutorial' } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['comments'].length).to eq(2)
      authors = json['comments'].map { |c| c['author'] }
      expect(authors).to match_array(['Alice', 'Bob'])
    end

    it 'filters comments by post published status' do
      get '/api/v1/comments', params: { filter: { post: { published: { equal: true } } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['comments'].length).to eq(3)
    end

    it 'filters comments by post created_at' do
      get '/api/v1/comments', params: {
        filter: { post: { created_at: { greater_than: 2.5.days.ago.iso8601 } } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['comments'].length).to eq(2)
    end

    it 'combines comment filters with post filters' do
      get '/api/v1/comments', params: {
        filter: {
          author: { equal: 'Alice' },
          post: { published: { equal: true } }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['comments'].length).to eq(1)
      expect(json['comments'][0]['content']).to eq('Great tutorial!')
    end
  end

  describe 'Error handling' do
    it 'handles invalid association filter field gracefully' do
      get '/api/v1/posts', params: { filter: { comments: { invalid_field: { equal: 'value' } } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(false)
      expect(json['errors']).to be_present
    end
  end
end
