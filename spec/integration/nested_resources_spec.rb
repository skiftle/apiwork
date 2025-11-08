# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested Resources Routing', type: :request do
  before(:each) do
    # Delete comments first due to foreign key constraint
    Comment.delete_all
    Post.delete_all
  end

  let!(:post1) { Post.create!(title: 'Post 1', body: 'Body 1', published: true) }
  let!(:post2) { Post.create!(title: 'Post 2', body: 'Body 2', published: false) }
  let!(:comment1) { Comment.create!(post: post1, content: 'Comment 1 for Post 1', author: 'Author 1') }
  let!(:comment2) { Comment.create!(post: post1, content: 'Comment 2 for Post 1', author: 'Author 2') }
  let!(:comment3) { Comment.create!(post: post2, content: 'Comment 1 for Post 2', author: 'Author 3') }

  describe 'Nested Index: GET /posts/:post_id/comments' do
    it 'returns comments scoped to the parent post' do
      get "/api/v1/posts/#{post1.id}/comments"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to have_key('comments')
      expect(json['comments'].length).to eq(2)

      comment_contents = json['comments'].map { |c| c['content'] }
      expect(comment_contents).to contain_exactly('Comment 1 for Post 1', 'Comment 2 for Post 1')
    end

    it 'returns different comments for different posts' do
      get "/api/v1/posts/#{post2.id}/comments"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comments'].length).to eq(1)
      expect(json['comments'][0]['content']).to eq('Comment 1 for Post 2')
    end

    it 'returns empty array for post with no comments' do
      post3 = Post.create!(title: 'Post 3', body: 'Body 3', published: true)

      get "/api/v1/posts/#{post3.id}/comments"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comments']).to eq([])
    end
  end

  describe 'Nested Show: GET /posts/:post_id/comments/:id' do
    it 'returns a specific comment from the parent post' do
      get "/api/v1/posts/#{post1.id}/comments/#{comment1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comment']['id']).to eq(comment1.id)
      expect(json['comment']['content']).to eq('Comment 1 for Post 1')
    end

    it 'returns 404 if comment belongs to different post' do
      get "/api/v1/posts/#{post2.id}/comments/#{comment1.id}"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 if comment does not exist' do
      get "/api/v1/posts/#{post1.id}/comments/99999"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Nested Create: POST /posts/:post_id/comments' do
    it 'creates a comment associated with the parent post' do
      comment_params = {
        comment: {
          content: 'New nested comment',
          author: 'New Author',
          post_id: post1.id # Still needed for validation, but route also provides it
        }
      }

      post "/api/v1/posts/#{post1.id}/comments", params: comment_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['comment']['content']).to eq('New nested comment')
      expect(json['comment']['author']).to eq('New Author')

      # Verify it's associated with the correct post
      created_comment = Comment.find(json['comment']['id'])
      expect(created_comment.post_id).to eq(post1.id)
    end

    it 'validates required fields' do
      comment_params = {
        comment: {
          content: '', # Required field empty - caught by model validation
          author: 'Author',
          post_id: post1.id
        }
      }

      post "/api/v1/posts/#{post1.id}/comments", params: comment_params, as: :json

      # Contract validation happens first (400), model validation happens later (422)
      # Empty string passes contract but fails model validation
      expect(response.status).to be_in([400, 422])
      json = JSON.parse(response.body)
      expect(json['ok']).to be false
    end
  end

  describe 'Nested Update: PATCH /posts/:post_id/comments/:id' do
    it 'updates a comment within the parent post scope' do
      comment_params = {
        comment: {
          content: 'Updated comment content',
          author: 'Updated Author',
          post_id: post1.id
        }
      }

      patch "/api/v1/posts/#{post1.id}/comments/#{comment1.id}", params: comment_params, as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comment']['content']).to eq('Updated comment content')
      expect(json['comment']['author']).to eq('Updated Author')
    end

    it 'returns 404 if trying to update comment from different post' do
      comment_params = {
        comment: {
          content: 'Trying to update',
          author: 'Author',
          post_id: post2.id
        }
      }

      patch "/api/v1/posts/#{post2.id}/comments/#{comment1.id}", params: comment_params, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Nested Destroy: DELETE /posts/:post_id/comments/:id' do
    it 'deletes a comment within the parent post scope' do
      delete "/api/v1/posts/#{post1.id}/comments/#{comment1.id}"

      expect(response).to have_http_status(:ok)
      expect(Comment.find_by(id: comment1.id)).to be_nil
    end

    it 'returns 404 if trying to delete comment from different post' do
      delete "/api/v1/posts/#{post2.id}/comments/#{comment1.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Nested Member Action: PATCH /posts/:post_id/comments/:id/approve' do
    it 'calls the approve action on a nested comment' do
      patch "/api/v1/posts/#{post1.id}/comments/#{comment1.id}/approve"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comment']['id']).to eq(comment1.id)
    end

    it 'returns 404 if comment belongs to different post' do
      patch "/api/v1/posts/#{post2.id}/comments/#{comment1.id}/approve"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Nested Collection Action: GET /posts/:post_id/comments/recent' do
    it 'calls the recent action scoped to the parent post' do
      get "/api/v1/posts/#{post1.id}/comments/recent"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json).to have_key('comments')
      expect(json['comments'].length).to eq(2)

      # All should belong to post1
      json['comments'].each do |comment|
        found_comment = Comment.find(comment['id'])
        expect(found_comment.post_id).to eq(post1.id)
      end
    end

    it 'returns recent comments in descending order' do
      # Create comments with different timestamps
      sleep 0.01
      new_comment = Comment.create!(post: post1, content: 'Newest comment', author: 'Author')

      get "/api/v1/posts/#{post1.id}/comments/recent"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      # First comment should be the newest
      expect(json['comments'].first['id']).to eq(new_comment.id)
    end
  end

  describe 'Non-nested vs Nested routes coexistence' do
    it 'non-nested routes still work independently' do
      # Non-nested index
      get '/api/v1/comments'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['comments'].length).to eq(3) # All comments

      # Non-nested show
      get "/api/v1/comments/#{comment1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['comment']['id']).to eq(comment1.id)
    end

    it 'nested routes are properly scoped' do
      # Nested index (scoped)
      get "/api/v1/posts/#{post1.id}/comments"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['comments'].length).to eq(2) # Only post1 comments
    end
  end
end
