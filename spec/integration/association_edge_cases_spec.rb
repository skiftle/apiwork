# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Association Edge Cases' do
  describe 'Dependent destroy cascades' do
    it 'cascades delete from post to comments when deleting post' do
      post = Post.create!(title: 'Parent Post', body: 'Content')
      comment1 = post.comments.create!(content: 'Comment 1')
      comment2 = post.comments.create!(content: 'Comment 2')

      expect(Comment.count).to eq(2)

      delete "/api/v1/posts/#{post.id}"

      # PostContract explicitly defines a response body for destroy, so it returns 200 OK
      expect(response).to have_http_status(:ok)
      expect(Post.exists?(post.id)).to be(false)
      expect(Comment.exists?(comment1.id)).to be(false)
      expect(Comment.exists?(comment2.id)).to be(false)
    end

    it 'cascades delete from comment to replies when deleting comment' do
      post = Post.create!(title: 'Post', body: 'Content')
      comment = post.comments.create!(content: 'Comment')
      reply1 = comment.replies.create!(content: 'Reply 1', author: 'User1')
      reply2 = comment.replies.create!(content: 'Reply 2', author: 'User2')

      expect(Reply.count).to eq(2)

      delete "/api/v1/posts/#{post.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:no_content)
      expect(Comment.exists?(comment.id)).to be(false)
      expect(Reply.exists?(reply1.id)).to be(false)
      expect(Reply.exists?(reply2.id)).to be(false)
    end

    it 'cascades through multiple levels when deleting top-level resource' do
      post = Post.create!(title: 'Post', body: 'Content')
      comment = post.comments.create!(content: 'Comment')
      reply = comment.replies.create!(content: 'Reply', author: 'User')

      delete "/api/v1/posts/#{post.id}"

      # PostContract explicitly defines a response body for destroy, so it returns 200 OK
      expect(response).to have_http_status(:ok)
      expect(Post.exists?(post.id)).to be(false)
      expect(Comment.exists?(comment.id)).to be(false)
      expect(Reply.exists?(reply.id)).to be(false)
    end

    it 'correctly handles multiple records at each cascade level' do
      post1 = Post.create!(title: 'Post 1', body: 'Content')
      post2 = Post.create!(title: 'Post 2', body: 'Content')

      comment1_1 = post1.comments.create!(content: 'Post1 Comment1')
      comment1_2 = post1.comments.create!(content: 'Post1 Comment2')
      comment2_1 = post2.comments.create!(content: 'Post2 Comment1')

      comment1_1.replies.create!(content: 'Reply to 1_1', author: 'User')
      comment1_2.replies.create!(content: 'Reply to 1_2', author: 'User')
      comment2_1.replies.create!(content: 'Reply to 2_1', author: 'User')

      expect(Post.count).to eq(2)
      expect(Comment.count).to eq(3)
      expect(Reply.count).to eq(3)

      post1.destroy

      expect(Post.count).to eq(1)
      expect(Comment.count).to eq(1)
      expect(Reply.count).to eq(1)
    end
  end

  describe 'Cross-post association queries' do
    before do
      post1 = Post.create!(title: 'Post 1', body: 'Content')
      post2 = Post.create!(title: 'Post 2', body: 'Content')
      post1.comments.create!(content: 'Comment for post 1')
      post1.comments.create!(content: 'Another comment for post 1')
      post2.comments.create!(content: 'Comment for post 2')
    end

    it 'filters nested comments by parent post' do
      post1 = Post.find_by(title: 'Post 1')

      get "/api/v1/posts/#{post1.id}/comments"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['comments'].length).to eq(2)

      contents = json['comments'].map { |c| c['content'] }
      expect(contents).to all(include('post 1'))
    end

    it 'returns only comments for requested post, not others' do
      post2 = Post.find_by(title: 'Post 2')

      get "/api/v1/posts/#{post2.id}/comments"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['comments'].length).to eq(1)
      expect(json['comments'][0]['content']).to eq('Comment for post 2')
    end
  end

  describe 'Deletion of non-existent associations' do
    it 'returns 404 when deleting comment that does not exist' do
      post = Post.create!(title: 'Post', body: 'Content')

      delete "/api/v1/posts/#{post.id}/comments/99999"

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when accessing nested resource under wrong parent' do
      post1 = Post.create!(title: 'Post 1', body: 'Content')
      post2 = Post.create!(title: 'Post 2', body: 'Content')
      comment = post1.comments.create!(content: 'Comment for post 1')

      # Try to access post1's comment through post2
      get "/api/v1/posts/#{post2.id}/comments/#{comment.id}"

      expect(response).to have_http_status(:not_found)
    end
  end
end
