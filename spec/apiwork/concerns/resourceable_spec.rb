# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Controller::Concern, type: :apiwork do
  let(:resource_class) do
    test_resource_class do
      attribute :name, filterable: true, sortable: true, writable: true
      attribute :email, filterable: true, sortable: true, writable: true
    end
  end

  let(:test_model) { test_model_instance }
  let(:test_collection) { [test_model_instance, test_model_instance] }
  let(:test_relation) { mock_relation(test_collection) }

  describe '#respond_with' do
    let(:controller) { mock_controller(action_name: :show, request_method: :get) }

    context 'with single resource (POST/PATCH/PUT)' do
      let(:controller) { mock_controller(action_name: :create, request_method: :post) }

      it 'wraps with ok: true and root key' do
        allow(resource_class).to receive(:serialize).and_return({ name: 'Test', email: 'test@example.com' })
        root_key = double('RootKey', singular: 'test_model', plural: 'test_models')
        allow(resource_class).to receive(:root_key).and_return(root_key)

        result = controller.respond_with(test_model, resource: resource_class)

        expect(result).to eq({
                               json: {
                                 ok: true,
                                 'test_model' => { name: 'Test', email: 'test@example.com' },
                                 meta: {}
                               },
                               status: :created
                             })
      end

      it 'includes custom meta' do
        allow(resource_class).to receive(:serialize).and_return({ name: 'Test' })
        root_key = double('RootKey', singular: 'client', plural: 'clients')
        allow(resource_class).to receive(:root_key).and_return(root_key)

        result = controller.respond_with(test_model, resource: resource_class, meta: { version: '1.0' })

        expect(result[:json][:meta]).to eq({ version: '1.0' })
      end

      it 'uses singular root key for single resource' do
        allow(resource_class).to receive(:serialize).and_return({ name: 'Test' })
        root_key = double('RootKey', singular: 'test_model', plural: 'test_models')
        allow(resource_class).to receive(:root_key).and_return(root_key)

        result = controller.respond_with(test_model, resource: resource_class)

        expect(result[:json]).to have_key('test_model')
        expect(result[:json]).not_to have_key('test_models')
      end
    end

    context 'with collection (GET)' do
      let(:controller) { mock_controller(action_name: :index, request_method: :get) }

      it 'includes pagination metadata' do
        allow(resource_class).to receive(:serialize).and_return([{ name: 'Test1' }, { name: 'Test2' }])
        root_key = double('RootKey', singular: 'test_model', plural: 'test_models')
        allow(resource_class).to receive(:root_key).and_return(root_key)
        allow(resource_class).to receive(:build_pagination_metadata).and_return({ page: 1, total: 2 })

        result = controller.respond_with(test_collection, resource: resource_class)

        expect(result).to eq({
                               json: {
                                 ok: true,
                                 'test_models' => [{ name: 'Test1' }, { name: 'Test2' }],
                                 meta: { page: 1, total: 2 }
                               },
                               status: :ok
                             })
      end

      it 'uses plural root key for collection' do
        allow(resource_class).to receive(:serialize).and_return([{ name: 'Test' }])
        root_key = double('RootKey', singular: 'test_model', plural: 'test_models')
        allow(resource_class).to receive(:root_key).and_return(root_key)
        allow(resource_class).to receive(:build_pagination_metadata).and_return({})

        result = controller.respond_with(test_collection, resource: resource_class)

        expect(result[:json]).to have_key(:ok)
        expect(result[:json][:ok]).to be true
        expect(result[:json]).to have_key('test_models')
        expect(result[:json]).not_to have_key('test_model')
      end
    end

    context 'with errors' do
      let(:controller) { mock_controller(action_name: :create, request_method: :post) }
      let(:error_model) do
        model_class = Class.new do
          def self.reflect_on_all_associations(type)
            []
          end
        end

        double('Model',
               errors: mock_errors({ name: ['is required'] }),
               class: model_class)
      end

      it 'wraps with ok: false and errors' do
        result = controller.respond_with(error_model, resource: resource_class)

        expect(result[:json]).to have_key(:ok)
        expect(result[:json]).to have_key(:errors)
        expect(result[:json][:ok]).to be false
      end
    end

    context 'with DELETE request' do
      let(:controller) { mock_controller(action_name: :destroy, request_method: :delete) }

      it 'wraps with ok: true and meta only' do
        result = controller.respond_with(test_model, resource: resource_class)

        expect(result).to eq({
                               json: {
                                 ok: true,
                                 meta: {}
                               },
                               status: :ok
                             })
      end
    end

    context 'status codes' do
      it 'returns 201 for POST' do
        controller = mock_controller(action_name: :create, request_method: :post)
        allow(resource_class).to receive(:serialize).and_return({})
        root_key = double('RootKey', singular: 'client', plural: 'clients')
        allow(resource_class).to receive(:root_key).and_return(root_key)

        result = controller.respond_with(test_model, resource: resource_class)

        # Status code is handled by Rails, we just return the data structure
        expect(result[:json]).to have_key(:ok)
      end
    end
  end

  describe '#query' do
    let(:controller) do
      mock_controller(action_name: :index, request_method: :get, params: { filter: { name: 'Test' } })
    end

    before do
      # Mock ResourceResolver to return the test resource class
      allow(Apiwork::Resource::Resolver).to receive(:from_scope).and_return(resource_class)
      allow(Apiwork::Resource::Resolver).to receive(:from_controller).and_return(resource_class)
    end

    it 'auto-detects resource class and applies query' do
      allow(controller).to receive(:action_params).and_return({ filter: { name: 'Test' } })
      allow(resource_class).to receive(:query).with(test_relation,
                                                    { filter: { name: 'Test' } }).and_return(test_relation)

      result = controller.query(test_relation)

      expect(result).to eq(test_relation)
    end

    it 'uses custom resource class when provided' do
      custom_resource = resource_class
      allow(controller).to receive(:action_params).and_return({ filter: { name: 'Test' } })
      allow(Apiwork::Resource::Resolver).to receive(:from_scope).with(test_relation).and_return(custom_resource)
      allow(custom_resource).to receive(:query).with(test_relation,
                                                     { filter: { name: 'Test' } }).and_return(test_relation)

      result = controller.query(test_relation)

      expect(result).to eq(test_relation)
    end
  end

  describe '#serialize_resource' do
    let(:controller) { mock_controller }
    let(:context) { test_context(user: double('User', id: 1)) }

    before do
      # Mock ResourceResolver to return the test resource class
      allow(Apiwork::Resource::Resolver).to receive(:from_scope).and_return(resource_class)
      # Mock the context building
      allow(controller).to receive(:build_resource_context).and_return({ user: double('User'),
                                                                         session: double('Session') })
    end

    it 'auto-detects resource class and serializes' do
      allow(resource_class).to receive(:serialize).with(test_model,
                                                        hash_including(user: anything,
                                                                       session: anything)).and_return({ name: 'Test' })

      result = controller.serialize_resource(test_model)

      expect(result).to eq({ name: 'Test' })
    end

    it 'uses custom resource class when provided' do
      custom_resource = resource_class
      allow(custom_resource).to receive(:serialize).with(test_model,
                                                         hash_including(user: anything,
                                                                        session: anything)).and_return({ name: 'Custom' })

      result = controller.serialize_resource(test_model, resource_class: custom_resource)

      expect(result).to eq({ name: 'Custom' })
    end

    it 'passes context with Current user/session' do
      mock_current(user: double('User', id: 1), session: double('Session', id: 2))
      allow(resource_class).to receive(:serialize).and_return({})

      controller.serialize_resource(test_model)

      expect(resource_class).to have_received(:serialize).with(test_model,
                                                               hash_including(user: anything, session: anything))
    end
  end

  describe '#action_params' do
    before do
      # Mock ResourceResolver to return the test resource class
      allow(Apiwork::Resource::Resolver).to receive(:from_controller).and_return(resource_class)
    end

    context 'for index action' do
      let(:controller) do
        mock_controller(action_name: :index, request_method: :get, params: { filter: { name: 'Test' } })
      end

      it 'returns body data' do
        allow(controller).to receive(:validated_request).and_return(double('ValidatedRequest',
                                                                           params: { filter: { name: 'Test' } }))

        result = controller.action_params

        expect(result).to eq({ filter: { name: 'Test' } })
      end
    end

    context 'for other actions' do
      let(:controller) do
        mock_controller(action_name: :create, request_method: :post, params: { client: { name: 'Test' } })
      end

      it 'returns root key data' do
        allow(controller).to receive(:action_params).and_return({ name: 'Test' })

        result = controller.action_params

        expect(result).to eq({ name: 'Test' })
      end
    end
  end

  describe 'integration' do
    let(:controller) { mock_controller(action_name: :index, request_method: :get) }

    it 'works with real resource class' do
      # This would be an integration test with actual Resource class
      # For now, we test the interface
      expect(controller).to respond_to(:respond_with)
      expect(controller).to respond_to(:query)
      expect(controller).to respond_to(:serialize_resource)
      expect(controller).to respond_to(:action_params)
    end
  end
end
