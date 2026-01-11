# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested Resources with Includes', type: :request do
  describe 'GET /api/v1/posts/:post_id/comments with includes' do
    let!(:post_record) { Post.create!(body: 'Content', title: 'Test Post') }
    let!(:comment1) { Comment.create!(author: 'Author 1', content: 'Comment 1', post: post_record) }
    let!(:comment2) { Comment.create!(author: 'Author 2', content: 'Comment 2', post: post_record) }
    let!(:reply1) { Reply.create!(author: 'Replier', comment: comment1, content: 'Reply to comment 1') }

    it 'includes post association on nested comments' do
      get "/api/v1/posts/#{post_record.id}/comments", params: { include: { post: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comments']).to be_an(Array)
      expect(json['comments'].length).to eq(2)

      json['comments'].each do |comment|
        expect(comment['post']).to be_present
        expect(comment['post']['title']).to eq('Test Post')
      end
    end

    it 'includes replies association on nested comments' do
      get "/api/v1/posts/#{post_record.id}/comments", params: { include: { replies: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      comment_with_reply = json['comments'].find { |c| c['id'] == comment1.id }
      expect(comment_with_reply['replies']).to be_an(Array)
      expect(comment_with_reply['replies'].length).to eq(1)
    end

    it 'includes multiple associations on nested comments' do
      get "/api/v1/posts/#{post_record.id}/comments", params: { include: { post: true, replies: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      comment_with_reply = json['comments'].find { |c| c['id'] == comment1.id }
      expect(comment_with_reply['post']).to be_present
      expect(comment_with_reply['replies']).to be_present
    end
  end

  describe 'GET /api/v1/posts/:post_id/comments/:id with includes' do
    let!(:post_record) { Post.create!(body: 'Content', title: 'Test Post') }
    let!(:comment) { Comment.create!(author: 'Test Author', content: 'Test Comment', post: post_record) }
    let!(:reply) { Reply.create!(comment:, author: 'Replier', content: 'Test Reply') }

    it 'includes associations on nested show action' do
      get "/api/v1/posts/#{post_record.id}/comments/#{comment.id}", params: { include: { post: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comment']['post']).to be_present
      expect(json['comment']['post']['title']).to eq('Test Post')
    end

    it 'includes replies on nested show action' do
      get "/api/v1/posts/#{post_record.id}/comments/#{comment.id}", params: { include: { replies: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comment']['replies']).to be_an(Array)
      expect(json['comment']['replies'].length).to eq(1)
    end
  end

  describe 'POST /api/v1/posts/:post_id/comments' do
    let!(:post_record) { Post.create!(body: 'Content', title: 'Test Post') }

    it 'creates a nested comment using post_id from URL' do
      post "/api/v1/posts/#{post_record.id}/comments",
           as: :json,
           params: {
             comment: { author: 'New Author', content: 'New Comment', post_id: post_record.id },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      expect(json['comment']['content']).to eq('New Comment')
      expect(json['comment']['author']).to eq('New Author')
    end
  end

  describe 'Nested includes with deeply nested resources' do
    let!(:post_record) { Post.create!(body: 'Content', title: 'Test Post') }
    let!(:comment) { Comment.create!(author: 'Parent', content: 'Parent Comment', post: post_record) }
    let!(:reply) { Reply.create!(comment:, author: 'Replier', content: 'Reply content') }

    it 'includes associations on deeply nested resources' do
      get "/api/v1/posts/#{post_record.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:ok)
    end

    it 'includes replies with comment attribute' do
      get "/api/v1/posts/#{post_record.id}/comments/#{comment.id}", params: { include: { replies: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json['comment']['replies']).to be_an(Array)
      expect(json['comment']['replies'].first['content']).to eq('Reply content')
    end
  end

  describe 'Invalid includes on nested resources' do
    let!(:post_record) { Post.create!(body: 'Content', title: 'Test Post') }

    it 'rejects unknown include parameters' do
      get "/api/v1/posts/#{post_record.id}/comments", params: { include: { unknown_association: true } }

      expect(response).to have_http_status(:bad_request)
      json = JSON.parse(response.body)
      expect(json['issues']).to be_present
    end
  end
end
