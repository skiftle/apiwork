# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adapter configuration', type: :integration do
  describe 'API-level adapter configuration' do
    it 'applies pagination default_size' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.adapter_config.pagination.default_size).to eq(20)
    end

    it 'applies pagination max_size' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.adapter_config.pagination.max_size).to eq(200)
    end

    it 'applies key_format at API level' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.key_format).to eq(:keep)
    end
  end

  describe 'representation-level configuration override' do
    it 'overrides pagination strategy to cursor' do
      expect(Api::V1::ActivityRepresentation.adapter_config.pagination.strategy).to eq(:cursor)
    end
  end

  describe 'validation' do
    it 'rejects invalid key_format' do
      expect do
        Apiwork::API.define '/integration/configuration-invalid-key-format' do
          key_format :invalid_strategy
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'rejects non-integer pagination size' do
      expect do
        Apiwork::API.define '/integration/configuration-invalid-page-size' do
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
        Apiwork::API.define '/integration/configuration-unknown-adapter-option' do
          adapter do
            unknown_option 'value'
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Unknown option/)
    end
  end

  describe 'adapter method as getter and DSL' do
    it 'returns adapter instance when called without block' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.adapter).to be_a(Apiwork::Adapter::Base)
    end

    it 'stores adapter config when called with block' do
      api_class = Apiwork::API.find!('/api/v1')

      expect(api_class.adapter_config.pagination.default_size).to eq(20)
    end
  end
end
