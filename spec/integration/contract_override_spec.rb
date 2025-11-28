# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Override Option', type: :request do
  describe 'explicit contract: option overrides inference' do
    context 'when using existing v1 API with contract override' do
      before(:all) do
        Apiwork::API.draw '/api/override_test' do
          resources :articles, contract: 'post'
        end
      end

      after(:all) do
        Apiwork::API::Registry.unregister('/api/override_test')
      end

      it 'uses metadata to resolve explicit contract class' do
        api = Apiwork::API.find('/api/override_test')
        expect(api).to be_present

        articles_metadata = api.metadata.resources[:articles]
        expect(articles_metadata).to be_present
        expect(api.metadata.resolve_contract_class(articles_metadata)).to eq(Api::OverrideTest::PostContract)
      end

      it 'controller resolves to explicit contract from metadata' do
        request_double = instance_double(ActionDispatch::Request, path: '/api/override_test/articles')
        controller = Api::OverrideTest::ArticlesController.new

        allow(controller).to receive(:request).and_return(request_double)

        controller.send(:set_current_contract)
        contract = controller.send(:current_contract)

        expect(contract).to eq(Api::OverrideTest::PostContract)
      end
    end
  end

  describe 'auto-inferred contract without explicit option' do
    context 'when no contract: option is specified' do
      before(:all) do
        Apiwork::API.draw '/api/inference_test' do
          resources :posts
        end
      end

      after(:all) do
        Apiwork::API::Registry.unregister('/api/inference_test')
      end

      it 'infers contract class from resource name' do
        api = Apiwork::API.find('/api/inference_test')
        expect(api).to be_present

        posts_metadata = api.metadata.resources[:posts]
        expect(posts_metadata).to be_present
        expect(api.metadata.resolve_contract_class(posts_metadata)).to eq(Api::InferenceTest::PostContract)
      end

      it 'controller resolves to inferred contract' do
        request_double = instance_double(ActionDispatch::Request, path: '/api/inference_test/posts')
        controller = Api::InferenceTest::PostsController.new

        allow(controller).to receive(:request).and_return(request_double)

        controller.send(:set_current_contract)
        contract = controller.send(:current_contract)

        expect(contract).to eq(Api::InferenceTest::PostContract)
      end
    end
  end
end
