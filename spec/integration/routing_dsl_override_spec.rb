# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Routing DSL Override with only/except', type: :request do
  describe 'Restricted resources with only: [:index, :show]' do
    let!(:post1) { Post.create!(body: 'Body 1', published: true, title: 'Post 1') }
    let!(:post2) { Post.create!(body: 'Body 2', published: false, title: 'Post 2') }

    it 'allows index action' do
      get '/api/v1/restricted_posts'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('posts')
      expect(json['posts'].length).to eq(2)
    end

    it 'allows show action' do
      get "/api/v1/restricted_posts/#{post1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('post')
      expect(json['post']['title']).to eq('Post 1')
    end

    it 'restricts create action (404)' do
      post_params = {
        post: {
          title: 'New Post',
          body: 'Body',
          published: true
        }
      }

      post '/api/v1/restricted_posts', as: :json, params: post_params

      expect(response).to have_http_status(:not_found)
    end

    it 'restricts update action (404)' do
      post_params = {
        post: {
          title: 'Updated Title'
        }
      }

      patch "/api/v1/restricted_posts/#{post1.id}", as: :json, params: post_params

      expect(response).to have_http_status(:not_found)
    end

    it 'restricts destroy action (404)' do
      delete "/api/v1/restricted_posts/#{post1.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Restricted resources with except: [:destroy]' do
    let!(:post_for_comments) { Post.create!(body: 'Body', published: true, title: 'Post for Comments') }
    let!(:comment1) { Comment.create!(author: 'Author 1', content: 'Comment 1', post: post_for_comments) }
    let!(:comment2) { Comment.create!(author: 'Author 2', content: 'Comment 2', post: post_for_comments) }

    it 'allows index action' do
      get '/api/v1/safe_comments'

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('comments')
      expect(json['comments'].length).to eq(2)
    end

    it 'allows show action' do
      get "/api/v1/safe_comments/#{comment1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('comment')
      expect(json['comment']['content']).to eq('Comment 1')
    end

    it 'allows create action' do
      comment_params = {
        comment: {
          content: 'New Comment',
          author: 'New Author',
          post_id: post_for_comments.id
        }
      }

      post '/api/v1/safe_comments', as: :json, params: comment_params

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['comment']['content']).to eq('New Comment')
    end

    it 'allows update action' do
      comment_params = {
        comment: {
          content: 'Updated Comment',
          author: 'Updated Author',
          post_id: post_for_comments.id
        }
      }

      patch "/api/v1/safe_comments/#{comment1.id}", as: :json, params: comment_params

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['comment']['content']).to eq('Updated Comment')
    end

    it 'restricts destroy action (404)' do
      delete "/api/v1/safe_comments/#{comment1.id}"

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'Coexistence with unrestricted resources' do
    let!(:test_post) { Post.create!(body: 'Body', published: true, title: 'Test Post') }
    let!(:test_comment) { Comment.create!(author: 'Author', content: 'Test Comment', post: test_post) }

    it 'unrestricted posts allow all actions' do
      # Index
      get '/api/v1/posts'
      expect(response).to have_http_status(:ok)

      # Show
      get "/api/v1/posts/#{test_post.id}"
      expect(response).to have_http_status(:ok)

      # Create
      post '/api/v1/posts',
           as: :json,
           params: { post: {
             body: 'Body',
             published: true,
             title: 'New'
           } }
      expect(response).to have_http_status(:created)

      # Update
      patch "/api/v1/posts/#{test_post.id}", as: :json, params: { post: { title: 'Updated' } }
      expect(response).to have_http_status(:ok)

      # Destroy
      delete "/api/v1/posts/#{test_post.id}"
      expect(response).to have_http_status(:no_content)
    end

    it 'unrestricted comments allow all actions including destroy' do
      # Create
      post '/api/v1/comments',
           params: { comment: {
             author: 'Author',
             content: 'New',
             post_id: test_post.id
           } },
           as: :json
      expect(response).to have_http_status(:created)
      created_id = JSON.parse(response.body)['comment']['id']

      # Destroy
      delete "/api/v1/comments/#{created_id}"
      expect(response).to have_http_status(:no_content)
    end
  end
end
