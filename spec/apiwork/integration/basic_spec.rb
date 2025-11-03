# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Apiwork Basic Integration', type: :apiwork do
  describe 'test structure' do
    it 'can create test resource class' do
      resource_class = test_resource_class do
        attribute :name, filterable: true, sortable: true, writable: true
      end

      expect(resource_class).to be_a(Class)
      expect(resource_class).to respond_to(:attribute)
    end

    it 'can create test contract class' do
      contract_class = test_contract_class do
        input do
          param :name, type: :string, required: true
        end
      end

      expect(contract_class).to be_a(Class)
      expect(contract_class).to respond_to(:input)
    end

    it 'can create test model instance' do
      model = test_model_instance(name: 'Test Name', email: 'test@example.com')

      expect(model).to respond_to(:name)
      expect(model).to respond_to(:email)
      expect(model.name).to eq('Test Name')
      expect(model.email).to eq('test@example.com')
    end

    it 'can create test relation' do
      relation = mock_relation([test_model_instance, test_model_instance])

      expect(relation).to respond_to(:each)
      expect(relation).to respond_to(:map)
      expect(relation).to respond_to(:to_a)
    end

    it 'can create test context' do
      context = test_context(user: double('User', id: 1))

      expect(context).to be_a(Hash)
      expect(context[:user]).to be_present
    end

    it 'can create test pagination metadata' do
      metadata = test_pagination_metadata(page: 1, per_page: 25, total: 100)

      expect(metadata).to include(:page, :per_page, :total, :total_pages)
      expect(metadata[:page]).to eq(1)
      expect(metadata[:per_page]).to eq(25)
      expect(metadata[:total]).to eq(100)
      expect(metadata[:total_pages]).to eq(4)
    end
  end

  describe 'test helpers integration' do
    it 'can mock controller with Resourceable' do
      controller = mock_controller(action_name: :index, request_method: :get)

      expect(controller).to be_a(ActionController::Base)
      expect(controller).to respond_to(:action_name)
      expect(controller.action_name).to eq(:index)
    end

    it 'can mock request object' do
      request = mock_request(method: :get)

      expect(request).to respond_to(:get?)
      expect(request).to respond_to(:post?)
      expect(request.get?).to be true
      expect(request.post?).to be false
    end

    it 'can mock params' do
      params = mock_params({ name: 'Test', email: 'test@example.com' })

      expect(params).to be_a(ActionController::Parameters)
      expect(params[:name]).to eq('Test')
      expect(params[:email]).to eq('test@example.com')
    end

    it 'can mock Current context' do
      user = double('User', id: 1)
      session = double('Session', id: 2)

      mock_current(user: user, session: session)

      expect(Current.user).to eq(user)
      expect(Current.session).to eq(session)
    end
  end

  describe 'test directory structure' do
    it 'has correct test directories' do
      expect(Dir.exist?('spec/apiwork/concerns')).to be true
      expect(Dir.exist?('spec/apiwork/serialization')).to be true
      expect(Dir.exist?('spec/apiwork/query')).to be true
      expect(Dir.exist?('spec/apiwork/contract')).to be true
      expect(Dir.exist?('spec/apiwork/dsl')).to be true
      expect(Dir.exist?('spec/apiwork/routing')).to be true
      expect(Dir.exist?('spec/apiwork/generation')).to be true
      expect(Dir.exist?('spec/apiwork/integration')).to be true
    end

    it 'has test helper file' do
      expect(File.exist?('spec/support/apiwork_helpers.rb')).to be true
    end
  end
end
