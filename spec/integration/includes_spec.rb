# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Includes API', type: :request do
  let!(:post1) do
    Post.create!(body: 'Content', published: true, title: 'First Post').tap do |post|
      post.comments.create!(author: 'Alice', content: 'Great post!')
      post.comments.create!(author: 'Bob', content: 'Thanks!')
    end
  end

  let!(:post2) do
    Post.create!(body: 'More content', published: false, title: 'Second Post').tap do |post|
      post.comments.create!(author: 'Charlie', content: 'Interesting')
    end
  end

  describe 'GET /api/v1/posts with includes' do
    context 'without include parameter' do
      it 'does not include comments when include: :optional' do
        get '/api/v1/posts'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['posts'].first.keys).not_to include('comments')
      end
    end

    context 'with valid include parameter' do
      it 'includes comments when explicitly requested' do
        get '/api/v1/posts', params: { include: { comments: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        first_post = json['posts'].find { |p| p['title'] == 'First Post' }
        expect(first_post['comments']).to be_present
        expect(first_post['comments'].length).to eq(2)
        expect(first_post['comments'].first.keys).to include('content', 'author')
      end

      it 'works with filtering and sorting' do
        get '/api/v1/posts',
            params: {
              filter: { published: { eq: true } },
              include: { comments: true },
              sort: { title: 'asc' },
            }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['posts'].length).to eq(1)
        expect(json['posts'].first['comments']).to be_present
      end
    end
  end

  describe 'nested includes' do
    before do
      # For nested includes test, we need post association on comments to be include: :optional
      Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@include, :optional)

      # Reset contracts and rebuild
      Api::V1::PostContract.reset_build_state!
      Api::V1::CommentContract.reset_build_state!

      api = Apiwork::API.find('/api/v1')
      api&.type_system&.clear!
      api&.reset_contracts!
      api&.ensure_all_contracts_built!
    end

    after do
      # Restore schema instance variable (persists across prepare!)
      Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@include, :optional)
    end

    it 'supports nested includes' do
      get '/api/v1/posts',
          params: {
            include: {
              comments: {
                post: true,
              },
            },
          }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      first_post = json['posts'].first
      expect(first_post['comments']).to be_present
      # Each comment should include its post
      first_comment = first_post['comments'].first
      expect(first_comment['post']).to be_present
      expect(first_comment['post']['title']).to be_present
    end
  end

  describe 'contract validation for always included associations' do
    context 'when association has include: :always' do
      before do
        # Ensure CommentSchema.post is NOT always included (to avoid circular serialization)
        Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@include, :optional)

        # Temporarily set comments to include: :always
        Api::V1::PostSchema.association_definitions[:comments].instance_variable_set(:@include, :always)

        # Reset contracts and rebuild
        Api::V1::PostContract.reset_build_state!
        Api::V1::CommentContract.reset_build_state!

        api = Apiwork::API.find('/api/v1')
        api&.type_system&.clear!
        api&.reset_contracts!
        api&.ensure_all_contracts_built!
      end

      after do
        # Restore schema instance variables (persist across prepare!)
        Api::V1::PostSchema.association_definitions[:comments].instance_variable_set(:@include, :optional)
        Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@include, :optional)
      end

      it 'allows nested includes under include: :always association' do
        get '/api/v1/posts', params: { include: { comments: { post: true } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        # Comments should be automatically included (include: :always)
        first_post = json['posts'].first
        expect(first_post['comments']).to be_present

        # Nested post should be included via explicit param
        first_comment = first_post['comments'].first
        expect(first_comment['post']).to be_present
        expect(first_comment['post']['title']).to be_present
      end

      it 'automatically includes :always association without params' do
        get '/api/v1/posts'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        # Comments should be automatically included (include: :always)
        first_post = json['posts'].first
        expect(first_post['comments']).to be_present

        # But nested post should NOT be included (include: :optional, not requested)
        first_comment = first_post['comments'].first
        expect(first_comment.keys).not_to include('post')
      end

      it 'contract rejects boolean false for :always associations' do
        get '/api/v1/posts', params: { include: { comments: false } }

        # Contract validation should reject false for :always associations
        # because the IncludeType only has nested hash, no boolean variant
        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json['issues']).to be_present
      end
    end

    context 'when association has include: :optional (default)' do
      it 'allows including the association via include parameter' do
        get '/api/v1/posts', params: { include: { comments: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['posts'].first['comments']).to be_present
      end

      it 'does not include association by default' do
        get '/api/v1/posts'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['posts'].first.keys).not_to include('comments')
      end
    end
  end

  describe 'GET /api/v1/posts/:id with include' do
    it 'includes associations on show action' do
      get "/api/v1/posts/#{post1.id}", params: { include: { comments: true } }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['comments']).to be_present
      expect(json['post']['comments'].length).to eq(2)
      expect(json['post']['comments'].first.keys).to include('content', 'author')
    end

    it 'does not include associations when not requested' do
      get "/api/v1/posts/#{post1.id}"

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post'].keys).not_to include('comments')
    end
  end

  describe 'POST /api/v1/posts with include' do
    it 'includes associations on create action' do
      post '/api/v1/posts?include[comments]=true',
           headers: { 'CONTENT_TYPE' => 'application/json' },
           params: { post: {
             body: 'Content',
             published: true,
             title: 'New Post',
           } }.to_json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['post']).to have_key('comments')
      expect(json['post']['comments']).to eq([]) # No comments yet, but field is present
    end

    it 'does not include associations when not requested' do
      post '/api/v1/posts',
           as: :json,
           params: {
             post: {
               body: 'More content',
               published: false,
               title: 'Another Post',
             },
           }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['post'].keys).not_to include('comments')
    end
  end

  describe 'PATCH /api/v1/posts/:id with include' do
    it 'includes associations on update action' do
      patch "/api/v1/posts/#{post1.id}?include[comments]=true",
            headers: { 'CONTENT_TYPE' => 'application/json' },
            params: { post: { title: 'Updated Title' } }.to_json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['title']).to eq('Updated Title')
      expect(json['post']['comments']).to be_present
      expect(json['post']['comments'].length).to eq(2)
    end

    it 'does not include associations when not requested' do
      patch "/api/v1/posts/#{post2.id}",
            as: :json,
            params: {
              post: { title: 'Updated Second Post' },
            }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['title']).to eq('Updated Second Post')
      expect(json['post'].keys).not_to include('comments')
    end
  end

  describe 'PATCH /api/v1/posts/:id/archive with include (custom member action)' do
    it 'includes associations on custom member action' do
      patch "/api/v1/posts/#{post1.id}/archive?include[comments]=true", as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['published']).to be(false) # Archive sets published to false
      expect(json['post']['comments']).to be_present
      expect(json['post']['comments'].length).to eq(2)
    end

    it 'does not include associations when not requested' do
      patch "/api/v1/posts/#{post2.id}/archive", as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['post']['published']).to be(false)
      expect(json['post'].keys).not_to include('comments')
    end
  end
end
