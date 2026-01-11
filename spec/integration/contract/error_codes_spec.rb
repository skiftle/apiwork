# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Error Codes', type: :integration do
  describe 'ErrorCode.register' do
    it 'registers a custom error code' do
      Apiwork::ErrorCode.register :payment_failed, status: 402

      expect(Apiwork::ErrorCode.registered?(:payment_failed)).to be(true)
    end

    it 'registers error code with attach_path option' do
      Apiwork::ErrorCode.register :resource_locked, attach_path: true, status: 423

      error_code = Apiwork::ErrorCode.fetch(:resource_locked)
      expect(error_code.status).to eq(423)
      expect(error_code.attach_path?).to be(true)
    end

    it 'returns registered error code via fetch' do
      Apiwork::ErrorCode.register :custom_error, status: 418

      error_code = Apiwork::ErrorCode.fetch(:custom_error)
      expect(error_code.key).to eq(:custom_error)
      expect(error_code.status).to eq(418)
    end

    it 'raises error for invalid status codes' do
      expect do
        Apiwork::ErrorCode.register :invalid, status: 200
      end.to raise_error(ArgumentError, /Status must be 400-599/)
    end

    it 'allows overwriting existing error codes' do
      Apiwork::ErrorCode.register :custom, status: 400
      Apiwork::ErrorCode.register :custom, status: 422

      error_code = Apiwork::ErrorCode.fetch(:custom)
      expect(error_code.status).to eq(422)
    end

    it 'has default error codes pre-registered' do
      expect(Apiwork::ErrorCode.registered?(:not_found)).to be(true)
      expect(Apiwork::ErrorCode.registered?(:bad_request)).to be(true)
      expect(Apiwork::ErrorCode.registered?(:unauthorized)).to be(true)
      expect(Apiwork::ErrorCode.registered?(:forbidden)).to be(true)
      expect(Apiwork::ErrorCode.registered?(:unprocessable_entity)).to be(true)
      expect(Apiwork::ErrorCode.registered?(:internal_server_error)).to be(true)
    end

    it 'returns correct status for default codes' do
      expect(Apiwork::ErrorCode.fetch(:not_found).status).to eq(404)
      expect(Apiwork::ErrorCode.fetch(:bad_request).status).to eq(400)
      expect(Apiwork::ErrorCode.fetch(:unauthorized).status).to eq(401)
      expect(Apiwork::ErrorCode.fetch(:forbidden).status).to eq(403)
      expect(Apiwork::ErrorCode.fetch(:conflict).status).to eq(409)
    end
  end

  describe 'Action#raises declaration' do
    it 'accepts single error code' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'TestRaisesContract'
        end

        action :show do
          raises :not_found
        end
      end

      action = contract.actions[:show]
      expect(action).to be_present
    end

    it 'accepts multiple error codes' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'TestMultipleRaisesContract'
        end

        action :update do
          raises :not_found, :forbidden, :conflict
        end
      end

      action = contract.actions[:update]
      expect(action).to be_present
    end

    it 'raises ConfigurationError for unregistered error code' do
      expect do
        Class.new(Apiwork::Contract::Base) do
          def self.name
            'TestUnregisteredContract'
          end

          action :show do
            raises :totally_unknown_error
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Unknown error code :totally_unknown_error/)
    end

    it 'raises ConfigurationError when passing integer instead of symbol' do
      expect do
        Class.new(Apiwork::Contract::Base) do
          def self.name
            'TestIntegerErrorContract'
          end

          action :show do
            raises 404
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /raises must be symbols.*Use :not_found instead/)
    end

    it 'accepts custom registered error codes' do
      Apiwork::ErrorCode.register :insufficient_credits, status: 402

      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'TestCustomErrorContract'
        end

        action :purchase do
          raises :insufficient_credits
        end
      end

      action = contract.actions[:purchase]
      expect(action).to be_present
    end

    it 'merges error codes from multiple raises calls' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'TestMergeRaisesContract'
        end

        action :complex do
          raises :not_found
          raises :forbidden
          raises :conflict
        end
      end

      action = contract.actions[:complex]
      expect(action).to be_present
    end
  end

  describe 'API-level raises declaration' do
    let(:api_class) { Apiwork::API.find('/api/v1') }

    it 'declares global error codes for all actions' do
      expect(api_class).to be_present

      structure = api_class.structure
      expect(structure.raises).to include(:bad_request, :internal_server_error)
    end
  end

  describe 'ErrorCode in introspection' do
    let(:api_class) { Apiwork::API.find('/api/v1') }
    let(:introspection) { api_class.introspect }

    it 'includes raises in action introspection' do
      contract = Api::V1::PostContract
      contract.action_for(:show)

      contract_introspection = contract.introspect
      expect(contract_introspection.actions).to be_present
      expect(contract_introspection.actions).to have_key(:show)
    end

    it 'includes global raises from API in introspection' do
      expect(introspection.error_codes).to be_present

      error_code_keys = introspection.error_codes.keys
      expect(error_code_keys).to include(:bad_request, :internal_server_error)
    end

    it 'includes error code status in introspection' do
      bad_request = introspection.error_codes[:bad_request]
      expect(bad_request).to be_present
      expect(bad_request.to_h[:status]).to eq(400)
    end
  end

  describe 'expose_error with custom codes', type: :request do
    before do
      Apiwork::ErrorCode.register :insufficient_funds, status: 402
    end

    it 'uses built-in not_found error code' do
      get '/api/v1/posts/999999'

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json['issues'].first['code']).to eq('not_found')
    end

    it 'attaches path for error codes with attach_path: true' do
      get '/api/v1/posts/999999'

      json = JSON.parse(response.body)
      expect(json['issues'].first['path']).to eq(%w[posts 999999])
      expect(json['issues'].first['pointer']).to eq('/posts/999999')
    end

    it 'uses i18n for error detail messages' do
      get '/api/v1/posts/999999'

      json = JSON.parse(response.body)
      expect(json['issues'].first['detail']).to be_a(String)
      expect(json['issues'].first['detail']).not_to be_empty
    end
  end
end
