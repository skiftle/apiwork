# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Error Codes', type: :integration do
  describe 'ErrorCode.register' do
    it 'registers a custom error code' do
      Apiwork::ErrorCode.register :payment_failed, status: 402

      expect(Apiwork::ErrorCode.exists?(:payment_failed)).to be(true)
    end

    it 'returns correct status and key' do
      Apiwork::ErrorCode.register :rate_limited, status: 429

      error_code = Apiwork::ErrorCode.find!(:rate_limited)
      expect(error_code.key).to eq(:rate_limited)
      expect(error_code.status).to eq(429)
    end

    it 'supports attach_path option' do
      Apiwork::ErrorCode.register :resource_locked, attach_path: true, status: 423

      error_code = Apiwork::ErrorCode.find!(:resource_locked)
      expect(error_code.attach_path?).to be(true)
    end

    it 'raises error for invalid status codes' do
      expect do
        Apiwork::ErrorCode.register :invalid, status: 200
      end.to raise_error(ArgumentError, /Status must be 400-599/)
    end

    it 'has default error codes pre-registered' do
      expect(Apiwork::ErrorCode.exists?(:not_found)).to be(true)
      expect(Apiwork::ErrorCode.exists?(:bad_request)).to be(true)
      expect(Apiwork::ErrorCode.exists?(:unauthorized)).to be(true)
      expect(Apiwork::ErrorCode.exists?(:forbidden)).to be(true)
      expect(Apiwork::ErrorCode.exists?(:unprocessable_entity)).to be(true)
    end

    it 'returns correct status for default codes' do
      expect(Apiwork::ErrorCode.find!(:not_found).status).to eq(404)
      expect(Apiwork::ErrorCode.find!(:bad_request).status).to eq(400)
      expect(Apiwork::ErrorCode.find!(:unauthorized).status).to eq(401)
      expect(Apiwork::ErrorCode.find!(:forbidden).status).to eq(403)
      expect(Apiwork::ErrorCode.find!(:conflict).status).to eq(409)
    end
  end

  describe 'Action#raises declaration' do
    it 'accepts single error code' do
      contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'InvoiceShowContract'
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
          'InvoiceUpdateContract'
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
            'UnknownErrorContract'
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
            'IntegerErrorContract'
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
          'PurchaseContract'
        end

        action :purchase do
          raises :insufficient_credits
        end
      end

      action = contract.actions[:purchase]
      expect(action).to be_present
    end
  end

  describe 'API-level raises declaration' do
    let(:api_class) { Apiwork::API.find!('/api/v1') }

    it 'declares global error codes for all actions' do
      expect(api_class.raises).to include(:bad_request, :internal_server_error)
    end
  end

  describe 'ErrorCode access' do
    it 'exposes error code details via find' do
      bad_request = Apiwork::ErrorCode.find!(:bad_request)

      expect(bad_request).to be_present
      expect(bad_request.status).to eq(400)
    end

    it 'raises KeyError for unknown error code via find!' do
      expect do
        Apiwork::ErrorCode.find!(:nonexistent_code)
      end.to raise_error(KeyError)
    end
  end
end
