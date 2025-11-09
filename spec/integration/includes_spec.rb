# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Includes API', type: :request do
  before(:each) do
    # Clean database before each test (delete comments first due to foreign key)
    Comment.delete_all
    Post.delete_all
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
          filter: { published: { eq: true } },
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

    # TODO: Add contract validation tests for include parameter
    # Contract validates structure and catches typos
    # context 'with invalid include parameter' do
    #   it 'returns validation error for non-existent association'
    #   it 'returns validation error for invalid value type'
    # end

    # TODO: Add show/create/update tests once includes are supported in those actions
    # Currently includes only work in index (query) action
  end

  describe 'nested includes' do
    before do
      # For nested includes test, we need post association on comments to be serializable: false
      Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@serializable, false)

      # Clear PostContract and CommentContract cache
      if defined?(Api::V1::PostContract)
        Api::V1::PostContract.instance_variable_set(:@custom_types, {}) if Api::V1::PostContract.instance_variable_defined?(:@custom_types)
        Api::V1::PostContract.instance_variable_set(:@action_definitions, {}) if Api::V1::PostContract.instance_variable_defined?(:@action_definitions)
      end
      if defined?(Api::V1::CommentContract)
        Api::V1::CommentContract.instance_variable_set(:@custom_types, {}) if Api::V1::CommentContract.instance_variable_defined?(:@custom_types)
        Api::V1::CommentContract.instance_variable_set(:@action_definitions, {}) if Api::V1::CommentContract.instance_variable_defined?(:@action_definitions)
      end

      # Clear descriptor registry cache for the include type
      Apiwork::Contract::Descriptors::Registry.instance_variable_set(:@types, {}) if Apiwork::Contract::Descriptors::Registry.instance_variable_defined?(:@types)
    end

    after do
      # Restore
      Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@serializable, true)

      # Clear cache
      if defined?(Api::V1::PostContract)
        Api::V1::PostContract.instance_variable_set(:@custom_types, {}) if Api::V1::PostContract.instance_variable_defined?(:@custom_types)
        Api::V1::PostContract.instance_variable_set(:@action_definitions, {}) if Api::V1::PostContract.instance_variable_defined?(:@action_definitions)
      end
      if defined?(Api::V1::CommentContract)
        Api::V1::CommentContract.instance_variable_set(:@custom_types, {}) if Api::V1::CommentContract.instance_variable_defined?(:@custom_types)
        Api::V1::CommentContract.instance_variable_set(:@action_definitions, {}) if Api::V1::CommentContract.instance_variable_defined?(:@action_definitions)
      end

      # Clear descriptor registry cache
      Apiwork::Contract::Descriptors::Registry.instance_variable_set(:@types, {}) if Apiwork::Contract::Descriptors::Registry.instance_variable_defined?(:@types)
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

  describe 'contract validation for serializable associations' do
    context 'when association has serializable: true' do
      before do
        # Ensure CommentSchema.post is NOT serializable (to avoid circular serialization)
        Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@serializable, false)

        # Temporarily set comments to serializable: true
        Api::V1::PostSchema.association_definitions[:comments].instance_variable_set(:@serializable, true)

        # Clear contract cache to pick up the change
        if defined?(Api::V1::PostContract)
          Api::V1::PostContract.instance_variable_set(:@custom_types, {}) if Api::V1::PostContract.instance_variable_defined?(:@custom_types)
          Api::V1::PostContract.instance_variable_set(:@action_definitions, {}) if Api::V1::PostContract.instance_variable_defined?(:@action_definitions)
        end
        if defined?(Api::V1::CommentContract)
          Api::V1::CommentContract.instance_variable_set(:@custom_types, {}) if Api::V1::CommentContract.instance_variable_defined?(:@custom_types)
          Api::V1::CommentContract.instance_variable_set(:@action_definitions, {}) if Api::V1::CommentContract.instance_variable_defined?(:@action_definitions)
        end

        # Clear descriptor registry cache for the include type
        Apiwork::Contract::Descriptors::Registry.instance_variable_set(:@types, {}) if Apiwork::Contract::Descriptors::Registry.instance_variable_defined?(:@types)
      end

      after do
        # Restore to serializable: false
        Api::V1::PostSchema.association_definitions[:comments].instance_variable_set(:@serializable, false)
        Api::V1::CommentSchema.association_definitions[:post].instance_variable_set(:@serializable, false)

        # Clear contract cache
        if defined?(Api::V1::PostContract)
          Api::V1::PostContract.instance_variable_set(:@custom_types, {}) if Api::V1::PostContract.instance_variable_defined?(:@custom_types)
          Api::V1::PostContract.instance_variable_set(:@action_definitions, {}) if Api::V1::PostContract.instance_variable_defined?(:@action_definitions)
        end
        if defined?(Api::V1::CommentContract)
          Api::V1::CommentContract.instance_variable_set(:@custom_types, {}) if Api::V1::CommentContract.instance_variable_defined?(:@custom_types)
          Api::V1::CommentContract.instance_variable_set(:@action_definitions, {}) if Api::V1::CommentContract.instance_variable_defined?(:@action_definitions)
        end

        # Clear descriptor registry cache
        Apiwork::Contract::Descriptors::Registry.instance_variable_set(:@types, {}) if Apiwork::Contract::Descriptors::Registry.instance_variable_defined?(:@types)
      end

      it 'accepts but ignores top-level boolean for serializable: true association' do
        get '/api/v1/posts', params: { include: { comments: true } }

        # Contract allows it (comments: true is valid shorthand for comments: {})
        # but it's redundant since comments is already auto-included via serializable: true
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)

        # Comments should be included (would be included anyway due to serializable: true)
        first_post = json['posts'].first
        expect(first_post['comments']).to be_present
      end

      it 'allows nested includes under serializable: true association' do
        get '/api/v1/posts', params: { include: { comments: { post: true } } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)

        # Comments should be automatically included (serializable: true)
        first_post = json['posts'].first
        expect(first_post['comments']).to be_present

        # Nested post should be included via explicit param
        first_comment = first_post['comments'].first
        expect(first_comment['post']).to be_present
        expect(first_comment['post']['title']).to be_present
      end

      it 'automatically includes serializable association without nested params' do
        get '/api/v1/posts'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)

        # Comments should be automatically included (serializable: true)
        first_post = json['posts'].first
        expect(first_post['comments']).to be_present

        # But nested post should NOT be included (serializable: false, not requested)
        first_comment = first_post['comments'].first
        expect(first_comment.keys).not_to include('post')
      end
    end

    context 'when association has serializable: false (default)' do
      it 'allows including the association via include parameter' do
        get '/api/v1/posts', params: { include: { comments: true } }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)
        expect(json['posts'].first['comments']).to be_present
      end

      it 'does not include association by default' do
        get '/api/v1/posts'

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['ok']).to eq(true)
        expect(json['posts'].first.keys).not_to include('comments')
      end
    end
  end
end
