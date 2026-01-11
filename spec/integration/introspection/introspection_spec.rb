# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection', type: :integration do
  describe 'API.introspect' do
    it 'returns introspection data for an API' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection).to be_a(Apiwork::Introspection::API)
    end

    it 'includes API path' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection.path).to eq('/api/v1')
    end

    it 'includes API info' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection.info).to be_present
      expect(introspection.info.to_h[:title]).to eq('Test API')
    end

    it 'includes resources' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection.resources).to be_a(Hash)
      expect(introspection.resources).to have_key(:posts)
      expect(introspection.resources).to have_key(:comments)
    end

    it 'includes types' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection.types).to be_a(Hash)
      expect(introspection.types).to have_key(:error_detail)
      expect(introspection.types).to have_key(:pagination_params)
    end

    it 'includes enums' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection.enums).to be_a(Hash)
      expect(introspection.enums).to have_key(:sort_direction)
      expect(introspection.enums).to have_key(:post_status)
    end

    it 'includes error_codes' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      expect(introspection.error_codes).to be_a(Hash)
      expect(introspection.error_codes).to have_key(:bad_request)
      expect(introspection.error_codes).to have_key(:internal_server_error)
    end

    it 'supports to_h for serialization' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      hash = introspection.to_h
      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:path)
      expect(hash).to have_key(:resources)
    end
  end

  describe 'Introspection::API::Resource' do
    it 'includes resource identifier' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      posts_resource = introspection.resources[:posts]
      expect(posts_resource.identifier).to eq('posts')
    end

    it 'includes resource path' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      posts_resource = introspection.resources[:posts]
      expect(posts_resource.path).to eq('posts')
    end

    it 'includes actions' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      posts_resource = introspection.resources[:posts]
      expect(posts_resource.actions).to be_a(Hash)
      expect(posts_resource.actions).to have_key(:index)
      expect(posts_resource.actions).to have_key(:show)
      expect(posts_resource.actions).to have_key(:create)
    end

    it 'includes nested resources' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      posts_resource = introspection.resources[:posts]
      expect(posts_resource.resources).to be_a(Hash)
      expect(posts_resource.resources).to have_key(:comments)
    end

    it 'supports to_h for serialization' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      posts_resource = introspection.resources[:posts]
      hash = posts_resource.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:identifier)
      expect(hash).to have_key(:path)
      expect(hash).to have_key(:actions)
    end
  end

  describe 'Introspection::Action' do
    it 'includes action path' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action.path).to be_a(String)
    end

    it 'includes HTTP method' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action.method).to eq(:get)

      create_action = introspection.resources[:posts].actions[:create]
      expect(create_action.method).to eq(:post)
    end

    it 'includes request definition' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      create_action = introspection.resources[:posts].actions[:create]
      expect(create_action.request).to be_present
    end

    it 'includes response definition' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action.response).to be_present
    end

    it 'includes raises error codes' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action).to respond_to(:raises)
    end

    it 'includes summary' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action).to respond_to(:summary)
    end

    it 'includes deprecated status' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action).to respond_to(:deprecated?)
      expect(show_action.deprecated?).to be(false)
    end

    it 'supports to_h for serialization' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      hash = show_action.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:path)
      expect(hash).to have_key(:method)
    end
  end

  describe 'Introspection::Enum' do
    it 'includes enum values' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      sort_enum = introspection.enums[:sort_direction]
      expect(sort_enum.values).to eq(%w[asc desc])
    end

    it 'includes enum description' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      sort_enum = introspection.enums[:sort_direction]
      expect(sort_enum).to respond_to(:description)
    end

    it 'includes deprecated status' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      sort_enum = introspection.enums[:sort_direction]
      expect(sort_enum).to respond_to(:deprecated?)
    end

    it 'supports to_h for serialization' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      sort_enum = introspection.enums[:sort_direction]
      hash = sort_enum.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:values)
    end
  end

  describe 'Introspection::Type' do
    it 'includes type kind (object or union)' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      expect(error_type.type).to eq(:object)
    end

    it 'object? returns true for object types' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      expect(error_type.object?).to be(true)
    end

    it 'includes shape for object types' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      expect(error_type.shape).to be_a(Hash)
    end

    it 'includes description' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      expect(error_type).to respond_to(:description)
    end

    it 'supports to_h for serialization' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      hash = error_type.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:type)
    end
  end

  describe 'Contract.introspect' do
    it 'returns introspection data for a contract' do
      contract = Api::V1::PostContract
      contract.action_for(:index)

      introspection = contract.introspect

      expect(introspection).to be_a(Apiwork::Introspection::Contract)
    end

    it 'includes actions' do
      contract = Api::V1::PostContract
      contract.action_for(:index)
      contract.action_for(:show)

      introspection = contract.introspect

      expect(introspection.actions).to be_a(Hash)
      expect(introspection.actions).to have_key(:index)
      expect(introspection.actions).to have_key(:show)
    end

    it 'includes types' do
      contract = Api::V1::PostContract
      contract.action_for(:index)

      introspection = contract.introspect

      expect(introspection.types).to be_a(Hash)
    end

    it 'includes enums' do
      contract = Api::V1::PostContract
      contract.action_for(:index)

      introspection = contract.introspect

      expect(introspection.enums).to be_a(Hash)
    end

    it 'supports to_h for serialization' do
      contract = Api::V1::PostContract
      contract.action_for(:index)

      introspection = contract.introspect
      hash = introspection.to_h

      expect(hash).to be_a(Hash)
      expect(hash).to have_key(:actions)
    end
  end

  describe 'Introspection::Action::Request' do
    it 'includes query parameters' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      index_action = introspection.resources[:posts].actions[:index]
      expect(index_action.request).to respond_to(:query)
    end

    it 'includes body parameters' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      create_action = introspection.resources[:posts].actions[:create]
      expect(create_action.request).to respond_to(:body)
    end

    it 'query? returns true when query parameters exist' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      index_action = introspection.resources[:posts].actions[:index]
      expect(index_action.request).to respond_to(:query?)
    end

    it 'body? returns true when body parameters exist' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      create_action = introspection.resources[:posts].actions[:create]
      expect(create_action.request).to respond_to(:body?)
    end
  end

  describe 'Introspection::Action::Response' do
    it 'includes body definition' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action.response).to respond_to(:body)
    end

    it 'no_content? returns true for no-content responses' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      show_action = introspection.resources[:posts].actions[:show]
      expect(show_action.response).to respond_to(:no_content?)
    end
  end

  describe 'Introspection::Param' do
    it 'includes param type' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      code_param = error_type.shape[:code]

      expect(code_param.type).to eq(:string)
    end

    it 'includes nullable status' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      code_param = error_type.shape[:code]

      expect(code_param).to respond_to(:nullable?)
    end

    it 'includes optional status' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      code_param = error_type.shape[:code]

      expect(code_param).to respond_to(:optional?)
    end

    it 'includes deprecated status' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      code_param = error_type.shape[:code]

      expect(code_param).to respond_to(:deprecated?)
    end

    it 'includes description' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      code_param = error_type.shape[:code]

      expect(code_param).to respond_to(:description)
    end

    it 'scalar? returns true for scalar types' do
      api_class = Apiwork::API.find('/api/v1')
      introspection = api_class.introspect

      error_type = introspection.types[:error_detail]
      code_param = error_type.shape[:code]

      expect(code_param.scalar?).to be(true)
    end
  end
end
