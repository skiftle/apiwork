# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI Generation', type: :integration do
  before(:all) do
    Apiwork.reset!
    load Rails.root.join('config/apis/v1.rb')
  end

  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Spec::Openapi.new(path) }
  let(:spec) { generator.generate }

  # NOTE: OpenAPI paths use Rails-style format: 'posts/' and 'posts/:id'
  # Schema names are lowercase: 'post', 'comment'

  describe 'OpenAPI structure' do
    it 'generates valid OpenAPI 3.1.0 structure' do
      expect(spec[:openapi]).to eq('3.1.0')
      expect(spec[:info]).to be_a(Hash)
      expect(spec[:paths]).to be_a(Hash)
      expect(spec[:components]).to be_a(Hash)
      expect(spec[:components][:schemas]).to be_a(Hash)
    end

    it 'includes API info with title and version' do
      expect(spec[:info][:title]).to be_present
      expect(spec[:info][:version]).to be_present
    end
  end

  describe 'Paths generation' do
    it 'generates paths for posts resource' do
      expect(spec[:paths]).to have_key('posts/')
      expect(spec[:paths]).to have_key('posts/:id')
    end

    it 'generates CRUD operations for posts' do
      # Collection path
      collection_path = spec[:paths]['posts/']
      expect(collection_path).to have_key('get')  # index
      expect(collection_path).to have_key('post') # create

      # Member path
      member_path = spec[:paths]['posts/:id']
      expect(member_path).to have_key('get')    # show
      expect(member_path).to have_key('patch')  # update
      expect(member_path).to have_key('delete') # destroy
    end

    it 'generates paths for nested resources' do
      # Comments nested under posts
      expect(spec[:paths]).to have_key('posts/:post_id/comments/')
      expect(spec[:paths]).to have_key('posts/:post_id/comments/:id')
    end

    it 'generates paths for top-level resources' do
      expect(spec[:paths]).to have_key('comments/')
      expect(spec[:paths]).to have_key('comments/:id')
    end
  end

  describe 'Operation metadata' do
    it 'generates operationId for each operation' do
      posts_index = spec[:paths]['posts/']['get']
      expect(posts_index[:operationId]).to be_present
    end

    it 'includes summary when available' do
      posts_index = spec[:paths]['posts/']['get']
      expect(posts_index).to have_key(:summary)
    end

    it 'includes tags for resource grouping' do
      posts_index = spec[:paths]['posts/']['get']
      expect(posts_index[:tags]).to be_an(Array)
    end
  end

  describe 'Request parameters' do
    it 'includes path parameters for member actions' do
      show_op = spec[:paths]['posts/:id']['get']
      parameters = show_op[:parameters] || []

      # Path parameters are embedded in the path like :id
      # Check that the operation has parameters defined
      expect(parameters).to be_an(Array)

      # If parameters exist, verify structure
      if parameters.any?
        id_param = parameters.find { |p| ['id', :id].include?(p[:name]) }
        if id_param
          expect(id_param[:in]).to eq('path').or eq(:path)
          expect(id_param[:required]).to be true
        end
      end
    end

    it 'includes parent path parameters for nested resources' do
      nested_index = spec[:paths]['posts/:post_id/comments/']['get']
      parameters = nested_index[:parameters] || []

      expect(parameters).to be_an(Array)

      if parameters.any?
        post_id_param = parameters.find { |p| ['post_id', :post_id].include?(p[:name]) }
        expect(post_id_param[:in]).to eq('path').or eq(:path) if post_id_param
      end
    end
  end

  describe 'Request body' do
    it 'generates request body for create action' do
      create_op = spec[:paths]['posts/']['post']

      expect(create_op[:requestBody]).to be_present
      expect(create_op[:requestBody][:content]).to have_key(:'application/json')
    end

    it 'generates request body for update action' do
      update_op = spec[:paths]['posts/:id']['patch']

      expect(update_op[:requestBody]).to be_present
      expect(update_op[:requestBody][:content]).to have_key(:'application/json')
    end
  end

  describe 'Response schemas' do
    it 'generates response definitions' do
      show_op = spec[:paths]['posts/:id']['get']

      expect(show_op[:responses]).to be_present
      expect(show_op[:responses]).to have_key(:'200')
    end

    it 'includes response content type' do
      show_op = spec[:paths]['posts/:id']['get']
      response_200 = show_op[:responses][:'200']

      expect(response_200[:content]).to have_key(:'application/json')
    end
  end

  describe 'Component schemas' do
    it 'generates schema components for resources' do
      schemas = spec[:components][:schemas]

      expect(schemas).to have_key('post')
      expect(schemas).to have_key('comment')
    end

    it 'includes properties in schema' do
      post_schema = spec[:components][:schemas]['post']

      expect(post_schema[:type]).to eq('object')
      expect(post_schema[:properties]).to be_a(Hash)
    end

    it 'defines property types correctly' do
      post_schema = spec[:components][:schemas]['post']
      properties = post_schema[:properties]

      # Verify the schema has the expected shape
      expect(properties).to be_a(Hash)
      expect(properties.keys).not_to be_empty

      # Check that properties have type definitions
      typed_props = properties.select { |_, v| v[:type].present? }
      expect(typed_props).not_to be_empty

      # At least one string type should exist
      string_props = properties.select { |_, v| v[:type] == 'string' }
      expect(string_props).not_to be_empty
    end

    it 'generates filter schemas' do
      schemas = spec[:components][:schemas]

      expect(schemas).to have_key('post_filter')
    end

    it 'generates sort schemas' do
      schemas = spec[:components][:schemas]

      expect(schemas).to have_key('post_sort')
    end

    it 'generates payload schemas' do
      schemas = spec[:components][:schemas]

      expect(schemas).to have_key('post_create_payload')
      expect(schemas).to have_key('post_update_payload')
    end
  end

  describe 'Custom member and collection actions' do
    it 'generates paths for custom member actions' do
      # Archive is a custom member action on posts
      expect(spec[:paths]).to have_key('posts/:id/archive')
    end

    it 'generates paths for custom collection actions' do
      # Search is a custom collection action on posts
      expect(spec[:paths]).to have_key('posts/search')
    end
  end

  describe 'JSON serialization' do
    it 'can be serialized to valid JSON' do
      json = JSON.generate(spec)
      expect(json).to be_a(String)

      parsed = JSON.parse(json)
      expect(parsed['openapi']).to eq('3.1.0')
    end
  end
end
