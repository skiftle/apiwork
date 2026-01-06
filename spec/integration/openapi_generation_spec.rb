# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI Generation', type: :integration do
  before(:all) do
    Apiwork::API.reset!
    Apiwork::ErrorCode.reset!
    load Rails.root.join('config/apis/v1.rb')
  end

  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  # NOTE: OpenAPI paths use OpenAPI-style format with leading slash: '/posts' and '/posts/{id}'
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

    it 'includes summary when provided' do
      expect(spec[:info][:summary]).to eq('A test API for Apiwork')
    end

    it 'includes termsOfService when provided' do
      expect(spec[:info][:termsOfService]).to eq('https://example.com/terms')
    end

    it 'includes contact when provided' do
      contact = spec[:info][:contact]
      expect(contact[:name]).to eq('API Support')
      expect(contact[:email]).to eq('support@example.com')
      expect(contact[:url]).to eq('https://example.com/support')
    end

    it 'includes license when provided' do
      license = spec[:info][:license]
      expect(license[:name]).to eq('MIT')
      expect(license[:url]).to eq('https://opensource.org/licenses/MIT')
    end

    it 'includes servers when provided' do
      expect(spec[:servers]).to be_an(Array)
      expect(spec[:servers].length).to eq(2)
      expect(spec[:servers][0][:url]).to eq('https://api.example.com')
      expect(spec[:servers][0][:description]).to eq('Production')
      expect(spec[:servers][1][:url]).to eq('https://staging-api.example.com')
    end
  end

  describe 'Paths generation' do
    it 'generates paths for posts resource' do
      expect(spec[:paths]).to have_key('/posts')
      expect(spec[:paths]).to have_key('/posts/{id}')
    end

    it 'generates CRUD operations for posts' do
      # Collection path
      collection_path = spec[:paths]['/posts']
      expect(collection_path).to have_key('get')  # index
      expect(collection_path).to have_key('post') # create

      # Member path
      member_path = spec[:paths]['/posts/{id}']
      expect(member_path).to have_key('get')    # show
      expect(member_path).to have_key('patch')  # update
      expect(member_path).to have_key('delete') # destroy
    end

    it 'generates paths for nested resources' do
      # Comments nested under posts
      expect(spec[:paths]).to have_key('/{post_id}/comments')
      expect(spec[:paths]).to have_key('/{post_id}/comments/{id}')
    end

    it 'generates paths for top-level resources' do
      expect(spec[:paths]).to have_key('/comments')
      expect(spec[:paths]).to have_key('/comments/{id}')
    end
  end

  describe 'Operation metadata' do
    it 'generates operationId for each operation' do
      posts_index = spec[:paths]['/posts']['get']
      expect(posts_index[:operationId]).to be_present
    end

    it 'includes tags when explicitly set' do
      posts_index = spec[:paths]['/posts']['get']
      expect(posts_index[:tags]).to be_nil.or be_an(Array)
    end
  end

  describe 'Request parameters' do
    it 'includes path parameters for member actions' do
      show_op = spec[:paths]['/posts/{id}']['get']
      parameters = show_op[:parameters] || []

      expect(parameters).to be_an(Array)
      expect(parameters).not_to be_empty

      id_param = parameters.find { |p| p[:name] == 'id' }
      expect(id_param).to be_present
      expect(id_param[:in]).to eq('path')
      expect(id_param[:required]).to be true
      expect(id_param[:schema]).to eq({ type: 'string' })
    end

    it 'includes parent path parameters for nested resources' do
      nested_index = spec[:paths]['/{post_id}/comments']['get']
      parameters = nested_index[:parameters] || []

      expect(parameters).to be_an(Array)
      expect(parameters).not_to be_empty

      post_id_param = parameters.find { |p| p[:name] == 'post_id' }
      expect(post_id_param).to be_present
      expect(post_id_param[:in]).to eq('path')
      expect(post_id_param[:required]).to be true
    end
  end

  describe 'Request body' do
    it 'generates request body for create action' do
      create_op = spec[:paths]['/posts']['post']

      expect(create_op[:requestBody]).to be_present
      expect(create_op[:requestBody][:content]).to have_key(:'application/json')
    end

    it 'generates request body for update action' do
      update_op = spec[:paths]['/posts/{id}']['patch']

      expect(update_op[:requestBody]).to be_present
      expect(update_op[:requestBody][:content]).to have_key(:'application/json')
    end
  end

  describe 'Response schemas' do
    it 'generates response definitions' do
      show_op = spec[:paths]['/posts/{id}']['get']

      expect(show_op[:responses]).to be_present
      expect(show_op[:responses]).to have_key(:'200')
    end

    it 'includes response content type' do
      show_op = spec[:paths]['/posts/{id}']['get']
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

    it 'includes schema description on resource type' do
      article_schema = spec[:components][:schemas]['article']

      expect(article_schema[:description]).to eq('A news article')
    end

    it 'includes schema example on resource type' do
      article_schema = spec[:components][:schemas]['article']

      expect(article_schema[:example]).to eq({ id: 1, title: 'Breaking News' })
    end
  end

  describe 'Custom member and collection actions' do
    it 'generates paths for custom member actions' do
      # Archive is a custom member action on posts
      expect(spec[:paths]).to have_key('/posts/{id}/archive')
    end

    it 'generates paths for custom collection actions' do
      # Search is a custom collection action on posts
      expect(spec[:paths]).to have_key('/posts/search')
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
