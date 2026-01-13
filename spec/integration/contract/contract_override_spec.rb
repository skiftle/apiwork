# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Override Option', type: :request do
  describe 'explicit contract: option overrides inference' do
    context 'when using existing v1 API with contract override' do
      before do
        Apiwork::API.define '/api/override_test' do
          resources :articles, contract: 'post'
        end
      end

      it 'uses definition to resolve explicit contract class' do
        api_class = Apiwork::API.find!('/api/override_test')
        expect(api_class).to be_present

        resource = api_class.structure.resources[:articles]
        expect(resource).to be_present
        expect(resource.resolve_contract_class).to eq(Api::OverrideTest::PostContract)
      end

      it 'controller resolves to explicit contract from definition' do
        request_double = instance_double(ActionDispatch::Request, path: '/api/override_test/articles')
        controller = Api::OverrideTest::ArticlesController.new

        allow(controller).to receive(:request).and_return(request_double)

        resolved_class = controller.send(:contract_class)

        expect(resolved_class).to eq(Api::OverrideTest::PostContract)
      end
    end
  end

  describe 'auto-inferred contract without explicit option' do
    context 'when no contract: option is specified' do
      before do
        Apiwork::API.define '/api/inference_test' do
          resources :posts
        end
      end

      it 'infers contract class from resource name' do
        api_class = Apiwork::API.find!('/api/inference_test')
        expect(api_class).to be_present

        resource = api_class.structure.resources[:posts]
        expect(resource).to be_present
        expect(resource.resolve_contract_class).to eq(Api::InferenceTest::PostContract)
      end

      it 'controller resolves to inferred contract' do
        request_double = instance_double(ActionDispatch::Request, path: '/api/inference_test/posts')
        controller = Api::InferenceTest::PostsController.new

        allow(controller).to receive(:request).and_return(request_double)

        resolved_class = controller.send(:contract_class)

        expect(resolved_class).to eq(Api::InferenceTest::PostContract)
      end
    end
  end
end
