# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Action Metadata', type: :integration do
  before(:all) do
    Apiwork::API.reset!
    Apiwork::ErrorCode.reset!
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'Introspection' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }
    let(:posts) { introspection[:resources][:posts] }

    it 'includes summary from Contract' do
      expect(posts[:actions][:index][:summary]).to eq('List all posts')
    end

    it 'includes description from Contract' do
      expect(posts[:actions][:index][:description]).to eq('Returns a paginated list of all posts')
    end

    it 'includes tags from Contract' do
      expect(posts[:actions][:index][:tags]).to eq([:posts, :public])
    end

    it 'includes deprecated flag' do
      expect(posts[:actions][:destroy][:deprecated]).to be true
    end

    it 'includes custom operation_id' do
      expect(posts[:actions][:destroy][:operation_id]).to eq('deletePost')
    end

    it 'includes raises as symbols' do
      expect(posts[:actions][:show][:raises]).to include(:not_found, :forbidden)
    end
  end

  describe 'OpenAPI generation' do
    let(:spec) { Apiwork::Spec::Openapi.new('/api/v1').generate }

    it 'includes summary in operation' do
      expect(spec[:paths]['posts/']['get'][:summary]).to eq('List all posts')
    end

    it 'includes description in operation' do
      expect(spec[:paths]['posts/']['get'][:description]).to eq('Returns a paginated list of all posts')
    end

    it 'includes tags in operation' do
      tags = spec[:paths]['posts/']['get'][:tags]
      expect(tags).to include(:posts, :public)
    end

    it 'marks operation as deprecated' do
      expect(spec[:paths]['posts/{id}']['delete'][:deprecated]).to be true
    end

    it 'uses custom operationId' do
      expect(spec[:paths]['posts/{id}']['delete'][:operationId]).to eq('deletePost')
    end

    it 'generates error responses from raises' do
      show_op = spec[:paths]['posts/{id}']['get']
      expect(show_op[:responses]).to have_key(:'404')
      expect(show_op[:responses]).to have_key(:'403')
    end
  end

  describe 'i18n support' do
    let(:introspection) { Apiwork::API.introspect('/api/v1') }
    let(:posts) { introspection[:resources][:posts] }

    it 'uses i18n when no inline value' do
      expect(posts[:actions][:bulk_create][:summary]).to eq('Bulk create posts')
      expect(posts[:actions][:bulk_create][:description]).to eq('Create multiple posts in one request')
    end

    it 'prefers inline value over i18n' do
      expect(posts[:actions][:index][:summary]).to eq('List all posts')
    end

    it 'returns nil when no inline and no i18n' do
      expect(posts[:actions][:update][:summary]).to be_nil
    end
  end
end
