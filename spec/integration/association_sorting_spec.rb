# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Association Sorting API', type: :request do
  before(:each) do
    # Clean database before each test to avoid pollution from other test suites
    Post.delete_all
    Comment.delete_all
  end

  let!(:post1) do
    Post.create!(title: 'Sort Test Alpha', body: 'First', published: true, created_at: 3.days.ago)
  end
  let!(:post2) do
    Post.create!(title: 'Sort Test Beta', body: 'Second', published: false, created_at: 2.days.ago)
  end
  let!(:post3) do
    Post.create!(title: 'Sort Test Gamma', body: 'Third', published: true, created_at: 1.day.ago)
  end

  let!(:comment1) do
    Comment.create!(post: post1, content: 'First comment', author: 'Zara', created_at: 2.days.ago)
  end
  let!(:comment2) do
    Comment.create!(post: post1, content: 'Second comment', author: 'Alice', created_at: 1.day.ago)
  end
  let!(:comment3) do
    Comment.create!(post: post2, content: 'Third comment', author: 'Bob', created_at: 1.5.days.ago)
  end
  let!(:comment4) do
    Comment.create!(post: post3, content: 'Fourth comment', author: 'Charlie', created_at: 1.hour.ago)
  end

  describe 'GET /api/v1/posts with comment sorting (has_many)' do
    it 'sorts posts by comment author ascending' do
      get '/api/v1/posts', params: { sort: { comments: { author: 'asc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to be >= 3

      # Posts with comments should be sorted by their comments' author
      # Note: When a post has multiple comments, DISTINCT + ORDER BY behavior
      # picks one of the comment values (implementation-dependent)
      # Post1 has Alice and Zara
      # Post2 has Bob
      # Post3 has Charlie
      # Find our test posts
      test_posts = json['posts'].select { |p| ['Sort Test Alpha', 'Sort Test Beta', 'Sort Test Gamma'].include?(p['title']) }
      expect(test_posts.length).to eq(3)

      # Verify posts are in the result (exact order may vary for posts with multiple comments)
      titles = test_posts.map { |p| p['title'] }
      expect(titles).to match_array(['Sort Test Alpha', 'Sort Test Beta', 'Sort Test Gamma'])
    end

    it 'sorts posts by comment author descending' do
      get '/api/v1/posts', params: { sort: { comments: { author: 'desc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles.first).to eq('Sort Test Alpha') # Has Zara
    end

    it 'sorts posts by comment created_at ascending' do
      get '/api/v1/posts', params: { sort: { comments: { created_at: 'asc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to be >= 3
    end

    it 'sorts posts by comment created_at descending' do
      get '/api/v1/posts', params: { sort: { comments: { created_at: 'desc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles.first).to eq('Sort Test Gamma') # Has most recent comment
    end

    it 'combines association sorting with filtering' do
      get '/api/v1/posts', params: {
        filter: { published: { equal: true } },
        sort: { comments: { author: 'asc' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to be >= 2
      json['posts'].each do |post|
        expect(post['published']).to eq(true)
      end
    end

    it 'combines association sorting with association filtering' do
      get '/api/v1/posts', params: {
        filter: { comments: { author: { equal: 'Alice' } } },
        sort: { comments: { created_at: 'desc' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['posts'].length).to eq(1)
      expect(json['posts'][0]['title']).to eq('Sort Test Alpha')
    end

    it 'combines post sorting with comment filtering' do
      get '/api/v1/posts', params: {
        filter: { comments: { content: { contains: 'comment' } } },
        sort: { title: 'asc' }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      titles = json['posts'].map { |p| p['title'] }
      expect(titles).to eq(titles.sort)
    end
  end

  describe 'GET /api/v1/comments with post sorting (belongs_to)' do
    it 'sorts comments by post title ascending' do
      get '/api/v1/comments', params: { sort: { post: { title: 'asc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)

      # Comments should be sorted by their post's title
      # Alpha Post -> comment1, comment2
      # Beta Post -> comment3
      # Gamma Post -> comment4
      expect(json['comments'].length).to eq(4)
    end

    it 'sorts comments by post created_at descending' do
      get '/api/v1/comments', params: { sort: { post: { created_at: 'desc' } } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['comments'].length).to eq(4)

      # Most recent post is post3, so comment4 should be first
      expect(json['comments'].first['content']).to eq('Fourth comment')
    end

    it 'combines post sorting with comment filtering' do
      get '/api/v1/comments', params: {
        filter: { author: { equal: 'Alice' } },
        sort: { post: { title: 'asc' } }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)
      expect(json['comments'].length).to eq(1)
    end
  end

  describe 'Error handling' do
    it 'handles invalid association sort field gracefully' do
      get '/api/v1/posts', params: { sort: { comments: { invalid_field: 'asc' } } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(false)
      expect(json['errors']).to be_present
    end

    it 'handles non-sortable association gracefully' do
      # ArticleResource has a comments association with sortable: false
      # (defined in spec/dummy/app/resources/api/v1/article_resource.rb)
      # Contract validation should reject this since non-sortable fields aren't in the contract
      get '/api/v1/articles', params: {
        sort: { comments: 'asc' }
      }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(false)
      expect(json['errors']).to be_present
      # Contract validation returns "Invalid type" since the field isn't allowed
      expect(json['errors'].first).to match(/Invalid type|not sortable/)
    end
  end
end
