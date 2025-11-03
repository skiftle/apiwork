# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Includes API', type: :request do
  before(:each) do
    # Clean database before each test
    Post.delete_all
    Comment.delete_all

    # Temporarily set comments to serializable: false for testing includes
    Api::V1::PostResource.association_definitions[:comments].instance_variable_set(:@serializable, false)

    # Clear contract cache so types regenerate with updated association settings
    # This is only needed in tests where we modify association definitions at runtime
    Api::V1::PostContract.instance_variable_set(:@custom_types, {}) if Api::V1::PostContract.instance_variable_defined?(:@custom_types)
    Api::V1::PostContract.instance_variable_set(:@action_definitions, {}) if Api::V1::PostContract.instance_variable_defined?(:@action_definitions)
  end

  after(:each) do
    # Restore comments to serializable: true
    Api::V1::PostResource.association_definitions[:comments].instance_variable_set(:@serializable, true)

    # Clear cache again
    Api::V1::PostContract.instance_variable_set(:@custom_types, {}) if Api::V1::PostContract.instance_variable_defined?(:@custom_types)
    Api::V1::PostContract.instance_variable_set(:@action_definitions, {}) if Api::V1::PostContract.instance_variable_defined?(:@action_definitions)
  end

  let!(:post1) do
    Post.create!(title: 'First Post', body: 'Content', published: true).tap do |post|
      post.comments.create!(content: 'Great post!', author: 'Alice')
      post.comments.create!(content: 'Thanks!', author: 'Bob')
    end
  end

  let!(:post2) do
    Post.create!(title: 'Second Post', body: 'More content', published: false).tap do |post|
      post.comments.create!(content: 'Interesting', author: 'Charlie')
    end
  end

  describe 'GET /api/v1/posts with includes' do
    context 'without include parameter' do
      it 'does not include comments when serializable: false' do
        get '/api/v1/posts'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)
        expect(json['posts'].first.keys).not_to include('comments')
      end
    end

    context 'with valid include parameter' do
      it 'includes comments when explicitly requested' do
        get '/api/v1/posts', params: { include: { comments: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)

        first_post = json['posts'].find { |p| p['title'] == 'First Post' }
        expect(first_post['comments']).to be_present
        expect(first_post['comments'].length).to eq(2)
        expect(first_post['comments'].first.keys).to include('content', 'author')
      end

      it 'works with filtering and sorting' do
        get '/api/v1/posts', params: {
          filter: { published: { equal: true } },
          sort: { title: 'asc' },
          include: { comments: true }
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)
        expect(json['posts'].length).to eq(1)
        expect(json['posts'].first['comments']).to be_present
      end
    end

    # TODO: Add error handling at controller level to catch validation errors
    # Currently errors from validate_includes are raised as exceptions
    # context 'with invalid include parameter' do
    #   it 'returns validation error for non-existent association'
    #   it 'returns validation error for invalid value type'
    #   it 'returns validation error when trying to include serializable: true'
    # end

    # TODO: Add show/create/update tests once includes are supported in those actions
    # Currently includes only work in index (query) action
  end

  describe 'nested includes' do
    before do
      # For nested includes test, we need post association on comments to be serializable: false
      Api::V1::CommentResource.association_definitions[:post].instance_variable_set(:@serializable, false)

      # Clear CommentContract cache too
      if defined?(Api::V1::CommentContract)
        Api::V1::CommentContract.instance_variable_set(:@custom_types, {}) if Api::V1::CommentContract.instance_variable_defined?(:@custom_types)
        Api::V1::CommentContract.instance_variable_set(:@action_definitions, {}) if Api::V1::CommentContract.instance_variable_defined?(:@action_definitions)
      end
    end

    after do
      # Restore
      Api::V1::CommentResource.association_definitions[:post].instance_variable_set(:@serializable, true)

      # Clear cache
      if defined?(Api::V1::CommentContract)
        Api::V1::CommentContract.instance_variable_set(:@custom_types, {}) if Api::V1::CommentContract.instance_variable_defined?(:@custom_types)
        Api::V1::CommentContract.instance_variable_set(:@action_definitions, {}) if Api::V1::CommentContract.instance_variable_defined?(:@action_definitions)
      end
    end

    it 'supports nested includes' do
      get '/api/v1/posts', params: {
        include: {
          comments: {
            post: true
          }
        }
      }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['ok']).to eq(true)

      first_post = json['posts'].first
      expect(first_post['comments']).to be_present
      # Each comment should include its post
      first_comment = first_post['comments'].first
      expect(first_comment['post']).to be_present
      expect(first_comment['post']['title']).to be_present
    end
  end
end
