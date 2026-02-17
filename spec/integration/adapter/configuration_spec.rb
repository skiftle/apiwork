# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adapter configuration', type: :integration do
  describe 'API-level adapter configuration' do
    let(:config_test_api) do
      Apiwork::API.define '/api/config_test' do
        key_format :camel

        adapter do
          pagination do
            default_size 25
            max_size 100
          end
        end

        resources :invoices
      end
    end

    before do
      config_test_api
    end

    it 'applies pagination configuration' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        def self.name
          'Api::ConfigTest::InvoiceRepresentation'
        end
      end

      expect(representation_class.adapter_config.pagination.default_size).to eq(25)
      expect(representation_class.adapter_config.pagination.max_size).to eq(100)
    end

    it 'applies key_format at API level' do
      api_class = Apiwork::API.find!('/api/config_test')

      expect(api_class.key_format).to eq(:camel)
    end
  end

  describe 'representation-level configuration override' do
    let(:override_api) do
      Apiwork::API.define '/api/repr_override' do
        adapter do
          pagination do
            default_size 20
            max_size 200
          end
        end

        resources :invoices
      end
    end

    let(:representation_with_config) do
      Class.new(Apiwork::Representation::Base) do
        def self.name
          'Api::ReprOverride::InvoiceRepresentation'
        end

        adapter do
          pagination do
            default_size 50
            max_size 150
          end
        end
      end
    end

    before do
      override_api
      representation_with_config
    end

    it 'overrides API-level configuration' do
      expect(representation_with_config.adapter_config.pagination.default_size).to eq(50)
      expect(representation_with_config.adapter_config.pagination.max_size).to eq(150)
    end
  end

  describe 'resolution chain' do
    let(:resolution_api) do
      Apiwork::API.define '/api/resolution_chain' do
        adapter do
          pagination do
            default_size 20
            max_size 200
          end
        end

        resources :invoices
      end
    end

    before do
      resolution_api

      representation = Class.new(Apiwork::Representation::Base) do
        def self.name
          'Api::ResolutionChain::InvoiceRepresentation'
        end

        adapter do
          pagination do
            default_size 50
          end
        end
      end
      stub_const('Api::ResolutionChain::InvoiceRepresentation', representation)
    end

    it 'merges representation and API configuration' do
      representation = Api::ResolutionChain::InvoiceRepresentation

      expect(representation.adapter_config.pagination.default_size).to eq(50)
      expect(representation.adapter_config.pagination.max_size).to eq(200)
      expect(representation.adapter_config.pagination.strategy).to eq(:offset)
    end
  end

  describe 'validation' do
    it 'rejects invalid key_format' do
      expect do
        Apiwork::API.define '/api/invalid_key_format' do
          key_format :invalid_strategy
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'rejects non-integer pagination size' do
      expect do
        Apiwork::API.define '/api/invalid_page_size' do
          adapter do
            pagination do
              default_size 'not_an_integer'
            end
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be integer/)
    end

    it 'rejects unknown adapter options' do
      expect do
        Apiwork::API.define '/api/unknown_adapter_option' do
          adapter do
            unknown_option 'value'
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Unknown option/)
    end
  end

  describe 'adapter method as getter and DSL' do
    let(:dual_api) do
      Apiwork::API.define '/api/dual_adapter' do
        adapter do
          pagination do
            default_size 30
          end
        end

        resources :invoices
      end
    end

    before do
      dual_api
    end

    it 'returns adapter instance when called without block' do
      api_class = Apiwork::API.find!('/api/dual_adapter')

      expect(api_class.adapter).to be_a(Apiwork::Adapter::Base)
    end

    it 'stores adapter config when called with block' do
      api_class = Apiwork::API.find!('/api/dual_adapter')

      expect(api_class.adapter_config.pagination.default_size).to eq(30)
    end
  end
end
