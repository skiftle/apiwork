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
          body: 'Post body',
          comments: [
            { author: 'Author 1', content: 'First comment' },
            { author: 'Author 2', content: 'Second comment' },
          ],
          published: true,
          title: 'Post with Comments',
        },
      }

      post '/api/v1/posts', as: :json, params: post_params

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
          body: 'Post body',
          comments: [],
          published: true,
          title: 'Post without Comments',
        },
      }

      post '/api/v1/posts', as: :json, params: post_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      created_post = Post.find(json['post']['id'])
      expect(created_post.comments.count).to eq(0)
    end

    it 'creates a post without nested comments key' do
      post_params = {
        post: {
          body: 'Post body',
          published: true,
          title: 'Simple Post',
        },
      }

      post '/api/v1/posts', as: :json, params: post_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)

      created_post = Post.find(json['post']['id'])
      expect(created_post.comments.count).to eq(0)
    end
  end

  describe 'Updating with nested has_many' do
    let!(:post_record) do
      Post.create!(
        body: 'Existing body',
        published: true,
        title: 'Existing Post',
      )
    end
    let!(:comment1) { Comment.create!(author: 'Author 1', content: 'Existing comment 1', post: post_record) }
    let!(:comment2) { Comment.create!(author: 'Author 2', content: 'Existing comment 2', post: post_record) }

    it 'adds new comments to existing post' do
      post_params = {
        post: {
          comments: [
            {
              author: 'Author 1',
              content: 'Updated comment 1',
              id: comment1.id,
            },
            {
              author: 'Author 2',
              content: 'Updated comment 2',
              id: comment2.id,
            },
            { author: 'Author 3', content: 'New comment 3' },
          ],
          title: 'Updated Post',
        },
      }

      patch "/api/v1/posts/#{post_record.id}", as: :json, params: post_params

      expect(response).to have_http_status(:ok)

      post_record.reload
      expect(post_record.comments.count).to eq(3)
      expect(post_record.comments.pluck(:content)).to contain_exactly(
        'Updated comment 1',
        'Updated comment 2',
        'New comment 3',
      )
    end

    it 'updates existing comments' do
      post_params = {
        post: {
          comments: [
            {
              author: 'Modified Author',
              content: 'Modified comment',
              id: comment1.id,
              post_id: post_record.id,
            },
          ],
          title: 'Keep title',
        },
      }

      patch "/api/v1/posts/#{post_record.id}", as: :json, params: post_params

      expect(response).to have_http_status(:ok)

      comment1.reload
      expect(comment1.content).to eq('Modified comment')
      expect(comment1.author).to eq('Modified Author')
    end

    it 'destroys comments with _destroy flag' do
      post_params = {
        post: {
          comments: [
            { _destroy: true, id: comment1.id },
            {
              author: 'Author 2',
              content: 'Keep this comment',
              id: comment2.id,
              post_id: post_record.id,
            },
          ],
          title: 'Keep title',
        },
      }

      patch "/api/v1/posts/#{post_record.id}", as: :json, params: post_params

      expect(response).to have_http_status(:ok)

      post_record.reload
      expect(post_record.comments.count).to eq(1)
      expect(post_record.comments.first.id).to eq(comment2.id)
      expect(Comment.find_by(id: comment1.id)).to be_nil
    end

    it 'handles validation errors in nested comments' do
      post_params = {
        post: {
          comments: [
            { author: 'Author', content: '' }, # Invalid: content is required
          ],
          title: 'Updated Post',
        },
      }

      patch "/api/v1/posts/#{post_record.id}", as: :json, params: post_params

      expect(response).to have_http_status(:unprocessable_content)
      JSON.parse(response.body)
    end
  end

  describe 'Validation with nested attributes' do
    it 'validates required fields in nested comments' do
      post_params = {
        post: {
          body: 'Body',
          comments: [
            { author: 'Author', content: 'Valid comment' },
            { author: 'Invalid', content: '' }, # Missing required content
          ],
          published: true,
          title: 'Post',
        },
      }

      post '/api/v1/posts', as: :json, params: post_params

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'Parameter transformation' do
    it 'transforms comments to comments_attributes internally' do
      # This test verifies that the transformation happens correctly
      # by checking that Rails nested attributes work as expected
      post_params = {
        post: {
          body: 'Body',
          comments: [
            { author: 'Author', content: 'Comment via transformation' },
          ],
          published: true,
          title: 'Test Transformation',
        },
      }

      expect do
        post '/api/v1/posts', as: :json, params: post_params
      end.to change(Comment, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe 'Deep nesting (Post -> Comments -> Replies)' do
    describe 'Creating with deeply nested data' do
      it 'creates post with nested comments and replies' do
        post_params = {
          post: {
            body: 'Post body',
            comments: [
              {
                author: 'Author 1',
                content: 'First comment',
                replies: [
                  { author: 'Replier 1', content: 'Reply to first comment' },
                  { author: 'Replier 2', content: 'Another reply to first' },
                ],
              },
              {
                author: 'Author 2',
                content: 'Second comment',
                replies: [
                  { author: 'Replier 3', content: 'Reply to second comment' },
                ],
              },
            ],
            published: true,
            title: 'Post with Deep Nesting',
          },
        }

        post '/api/v1/posts', as: :json, params: post_params

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
          'Another reply to first',
        )

        second_comment = created_post.comments.find_by(content: 'Second comment')
        expect(second_comment.replies.count).to eq(1)
        expect(second_comment.replies.first.content).to eq('Reply to second comment')
      end

      it 'creates post with comment but no replies' do
        post_params = {
          post: {
            body: 'Body',
            comments: [
              {
                author: 'Author',
                content: 'Comment without replies',
                replies: [],
              },
            ],
            published: true,
            title: 'Post',
          },
        }

        post '/api/v1/posts', as: :json, params: post_params

        expect(Comment.count).to eq(1)
        expect(Reply.count).to eq(0)

        expect(response).to have_http_status(:created)
      end
    end

    describe 'Updating with deeply nested data' do
      let!(:post_record) { Post.create!(body: 'Body', published: true, title: 'Post') }
      let!(:comment) { Comment.create!(author: 'Author', content: 'Comment', post: post_record) }
      let!(:reply) { Reply.create!(author: 'Replier', comment: comment, content: 'Existing reply') }

      it 'updates existing replies and adds new ones' do
        post_params = {
          post: {
            comments: [
              {
                author: 'Author',
                content: 'Updated comment',
                id: comment.id,
                replies: [
                  {
                    author: 'Replier',
                    content: 'Updated reply',
                    id: reply.id,
                  },
                  { author: 'New Replier', content: 'New reply' },
                ],
              },
            ],
            title: 'Updated Post',
          },
        }

        expect do
          patch "/api/v1/posts/#{post_record.id}", as: :json, params: post_params
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
            comments: [
              {
                author: 'Author',
                content: 'Comment',
                id: comment.id,
                post_id: post_record.id,
                replies: [
                  { _destroy: true, id: reply.id },
                ],
              },
            ],
            title: 'Keep title',
          },
        }

        expect do
          patch "/api/v1/posts/#{post_record.id}", as: :json, params: post_params
        end.to change(Reply, :count).by(-1)

        expect(response).to have_http_status(:ok)
        expect(Reply.find_by(id: reply.id)).to be_nil
      end
    end

    describe 'Validation with deeply nested data' do
      it 'validates required fields in nested replies' do
        post_params = {
          post: {
            body: 'Body',
            comments: [
              {
                author: 'Author',
                content: 'Valid comment',
                replies: [
                  { author: 'Replier', content: '' }, # Invalid: content is required
                ],
              },
            ],
            published: true,
            title: 'Post',
          },
        }

        post '/api/v1/posts', as: :json, params: post_params

        expect(response).to have_http_status(:unprocessable_content)
        JSON.parse(response.body)
      end
    end

    describe 'Transformation verification' do
      it 'transforms replies to replies_attributes recursively' do
        post_params = {
          post: {
            body: 'Body',
            comments: [
              {
                author: 'Author',
                content: 'Comment',
                replies: [
                  { author: 'Replier', content: 'Reply via transformation' },
                ],
              },
            ],
            published: true,
            title: 'Test Deep Transformation',
          },
        }

        expect do
          post '/api/v1/posts', as: :json, params: post_params
        end.to change(Reply, :count).by(1)

        expect(response).to have_http_status(:created)

        created_post = Post.last
        expect(created_post.comments.first.replies.count).to eq(1)
        expect(created_post.comments.first.replies.first.content).to eq('Reply via transformation')
      end
    end
  end
end
