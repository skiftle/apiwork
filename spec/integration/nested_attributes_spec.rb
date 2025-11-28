# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Nested Attributes (accepts_nested_attributes_for)', type: :request do
  # Clear API registry before this test suite to ensure clean state
  # This is needed because other tests may register types that interfere
  before(:all) do
    Apiwork::API.reset!
  end

  describe 'Creating with nested has_many' do
    it 'creates a post with nested comments' do
      post_params = {
        post: {
          title: 'Post with Comments',
          body: 'Post body',
          published: true,
          comments: [
            { content: 'First comment', author: 'Author 1' },
            { content: 'Second comment', author: 'Author 2' }
          ]
        }
      }

      post '/api/v1/posts', params: post_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      # Verify post was created
      expect(json['post']['title']).to eq('Post with Comments')

      # Verify comments were created
      created_post = Post.find(json['post']['id'])
      expect(created_post.comments.count).to eq(2)
      expect(created_post.comments.pluck(:content)).to contain_exactly('First comment', 'Second comment')
    end

    it 'creates a post with empty comments array' do
      post_params = {
        post: {
          title: 'Post without Comments',
          body: 'Post body',
          published: true,
          comments: []
        }
      }

      post '/api/v1/posts', params: post_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      created_post = Post.find(json['post']['id'])
      expect(created_post.comments.count).to eq(0)
    end

    it 'creates a post without nested comments key' do
      post_params = {
        post: {
          title: 'Simple Post',
          body: 'Post body',
          published: true
        }
      }

      post '/api/v1/posts', params: post_params, as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      created_post = Post.find(json['post']['id'])
      expect(created_post.comments.count).to eq(0)
    end
  end

  describe 'Updating with nested has_many' do
    let!(:post_record) do
      Post.create!(
        title: 'Existing Post',
        body: 'Existing body',
        published: true
      )
    end
    let!(:comment1) { Comment.create!(post: post_record, content: 'Existing comment 1', author: 'Author 1') }
    let!(:comment2) { Comment.create!(post: post_record, content: 'Existing comment 2', author: 'Author 2') }

    it 'adds new comments to existing post' do
      post_params = {
        post: {
          title: 'Updated Post',
          comments: [
            { id: comment1.id, content: 'Updated comment 1', author: 'Author 1' },
            { id: comment2.id, content: 'Updated comment 2', author: 'Author 2' },
            { content: 'New comment 3', author: 'Author 3' }
          ]
        }
      }

      patch "/api/v1/posts/#{post_record.id}", params: post_params, as: :json

      expect(response).to have_http_status(:ok)

      post_record.reload
      expect(post_record.comments.count).to eq(3)
      expect(post_record.comments.pluck(:content)).to contain_exactly(
        'Updated comment 1',
        'Updated comment 2',
        'New comment 3'
      )
    end

    it 'updates existing comments' do
      post_params = {
        post: {
          title: 'Keep title',
          comments: [
            { id: comment1.id, content: 'Modified comment', author: 'Modified Author', post_id: post_record.id }
          ]
        }
      }

      patch "/api/v1/posts/#{post_record.id}", params: post_params, as: :json

      expect(response).to have_http_status(:ok)

      comment1.reload
      expect(comment1.content).to eq('Modified comment')
      expect(comment1.author).to eq('Modified Author')
    end

    it 'destroys comments with _destroy flag' do
      post_params = {
        post: {
          title: 'Keep title',
          comments: [
            { id: comment1.id, _destroy: true },
            { id: comment2.id, content: 'Keep this comment', author: 'Author 2', post_id: post_record.id }
          ]
        }
      }

      patch "/api/v1/posts/#{post_record.id}", params: post_params, as: :json

      expect(response).to have_http_status(:ok)

      post_record.reload
      expect(post_record.comments.count).to eq(1)
      expect(post_record.comments.first.id).to eq(comment2.id)
      expect(Comment.find_by(id: comment1.id)).to be_nil
    end

    it 'handles validation errors in nested comments' do
      post_params = {
        post: {
          title: 'Updated Post',
          comments: [
            { content: '', author: 'Author' } # Invalid: content is required
          ]
        }
      }

      patch "/api/v1/posts/#{post_record.id}", params: post_params, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      JSON.parse(response.body)
    end
  end

  describe 'Validation with nested attributes' do
    it 'validates required fields in nested comments' do
      post_params = {
        post: {
          title: 'Post',
          body: 'Body',
          published: true,
          comments: [
            { content: 'Valid comment', author: 'Author' },
            { content: '', author: 'Invalid' } # Missing required content
          ]
        }
      }

      post '/api/v1/posts', params: post_params, as: :json

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'Parameter transformation' do
    it 'transforms comments to comments_attributes internally' do
      # This test verifies that the transformation happens correctly
      # by checking that Rails nested attributes work as expected
      post_params = {
        post: {
          title: 'Test Transformation',
          body: 'Body',
          published: true,
          comments: [
            { content: 'Comment via transformation', author: 'Author' }
          ]
        }
      }

      expect do
        post '/api/v1/posts', params: post_params, as: :json
      end.to change(Comment, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'Deep nesting (Post -> Comments -> Replies)' do
    describe 'Creating with deeply nested data' do
      it 'creates post with nested comments and replies' do
        post_params = {
          post: {
            title: 'Post with Deep Nesting',
            body: 'Post body',
            published: true,
            comments: [
              {
                content: 'First comment',
                author: 'Author 1',
                replies: [
                  { content: 'Reply to first comment', author: 'Replier 1' },
                  { content: 'Another reply to first', author: 'Replier 2' }
                ]
              },
              {
                content: 'Second comment',
                author: 'Author 2',
                replies: [
                  { content: 'Reply to second comment', author: 'Replier 3' }
                ]
              }
            ]
          }
        }

        post '/api/v1/posts', params: post_params, as: :json

        expect(Post.count).to eq(1)
        expect(Comment.count).to eq(2)
        expect(Reply.count).to eq(3)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)

        created_post = Post.find(json['post']['id'])
        expect(created_post.comments.count).to eq(2)

        first_comment = created_post.comments.find_by(content: 'First comment')
        expect(first_comment.replies.count).to eq(2)
        expect(first_comment.replies.pluck(:content)).to contain_exactly(
          'Reply to first comment',
          'Another reply to first'
        )

        second_comment = created_post.comments.find_by(content: 'Second comment')
        expect(second_comment.replies.count).to eq(1)
        expect(second_comment.replies.first.content).to eq('Reply to second comment')
      end

      it 'creates post with comment but no replies' do
        post_params = {
          post: {
            title: 'Post',
            body: 'Body',
            published: true,
            comments: [
              {
                content: 'Comment without replies',
                author: 'Author',
                replies: []
              }
            ]
          }
        }

        post '/api/v1/posts', params: post_params, as: :json

        expect(Comment.count).to eq(1)
        expect(Reply.count).to eq(0)

        expect(response).to have_http_status(:created)
      end
    end

    describe 'Updating with deeply nested data' do
      let!(:post_record) { Post.create!(title: 'Post', body: 'Body', published: true) }
      let!(:comment) { Comment.create!(post: post_record, content: 'Comment', author: 'Author') }
      let!(:reply) { Reply.create!(comment: comment, content: 'Existing reply', author: 'Replier') }

      it 'updates existing replies and adds new ones' do
        post_params = {
          post: {
            title: 'Updated Post',
            comments: [
              {
                id: comment.id,
                content: 'Updated comment',
                author: 'Author',
                replies: [
                  { id: reply.id, content: 'Updated reply', author: 'Replier' },
                  { content: 'New reply', author: 'New Replier' }
                ]
              }
            ]
          }
        }

        expect do
          patch "/api/v1/posts/#{post_record.id}", params: post_params, as: :json
        end.to change(Reply, :count).by(1)

        expect(response).to have_http_status(:ok)

        comment.reload
        expect(comment.content).to eq('Updated comment')
        expect(comment.replies.count).to eq(2)

        reply.reload
        expect(reply.content).to eq('Updated reply')

        new_reply = comment.replies.find_by(content: 'New reply')
        expect(new_reply).to be_present
        expect(new_reply.author).to eq('New Replier')
      end

      it 'destroys replies with _destroy flag' do
        post_params = {
          post: {
            title: 'Keep title',
            comments: [
              {
                id: comment.id,
                content: 'Comment',
                author: 'Author',
                post_id: post_record.id,
                replies: [
                  { id: reply.id, _destroy: true }
                ]
              }
            ]
          }
        }

        expect do
          patch "/api/v1/posts/#{post_record.id}", params: post_params, as: :json
        end.to change(Reply, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(Reply.find_by(id: reply.id)).to be_nil
      end
    end

    describe 'Validation with deeply nested data' do
      it 'validates required fields in nested replies' do
        post_params = {
          post: {
            title: 'Post',
            body: 'Body',
            published: true,
            comments: [
              {
                content: 'Valid comment',
                author: 'Author',
                replies: [
                  { content: '', author: 'Replier' } # Invalid: content is required
                ]
              }
            ]
          }
        }

        post '/api/v1/posts', params: post_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        JSON.parse(response.body)
      end
    end

    describe 'Transformation verification' do
      it 'transforms replies to replies_attributes recursively' do
        post_params = {
          post: {
            title: 'Test Deep Transformation',
            body: 'Body',
            published: true,
            comments: [
              {
                content: 'Comment',
                author: 'Author',
                replies: [
                  { content: 'Reply via transformation', author: 'Replier' }
                ]
              }
            ]
          }
        }

        expect do
          post '/api/v1/posts', params: post_params, as: :json
        end.to change(Reply, :count).by(1)

        expect(response).to have_http_status(:created)

        created_post = Post.last
        expect(created_post.comments.first.replies.count).to eq(1)
        expect(created_post.comments.first.replies.first.content).to eq('Reply via transformation')
      end
    end
  end
end
