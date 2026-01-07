# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adapter Configuration Integration', type: :request do
  # Test adapter configuration features using ONLY public APIs and runtime behavior
  # The public API is: adapter blocks in API and Schema with resolve_option

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

        resources :posts
      end
    end

    before do
      config_test_api # Trigger let to create API
    end

    it 'applies API configuration via schema resolve_option' do
      schema_class = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::ConfigTest::PostSchema'
        end
      end

      # Should use API configuration via resolve_option
      expect(schema_class.resolve_option(:pagination, :default_size)).to eq(25)
      expect(schema_class.resolve_option(:pagination, :max_size)).to eq(100)
    end

    it 'applies key_format at API level' do
      api = Apiwork::API.find('/api/config_test')
      expect(api.key_format).to eq(:camel)
    end
  end

  describe 'Schema-level adapter configuration override' do
    let(:schema_override_api) do
      Apiwork::API.define '/api/schema_override' do
        key_format :camel

        adapter do
          pagination do
            default_size 20
            max_size 200
          end
        end

        resources :posts
      end
    end

    let(:schema_with_config) do
      Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::SchemaOverride::PostSchema'
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
      schema_override_api # Trigger let to create API
      schema_with_config  # Trigger let to create Schema
    end

    it 'schema adapter configuration overrides API adapter configuration' do
      # Schema overrides should win
      expect(schema_with_config.resolve_option(:pagination, :default_size)).to eq(50)
      expect(schema_with_config.resolve_option(:pagination, :max_size)).to eq(150)
    end

    it 'key_format is at API level' do
      api = Apiwork::API.find('/api/schema_override')
      expect(api.key_format).to eq(:camel)
    end
  end

  describe 'Resolution chain: Schema -> API -> Adapter default' do
    let(:resolution_api) do
      Apiwork::API.define '/api/resolution' do
        key_format :camel

        adapter do
          pagination do
            default_size 20
            max_size 200
          end
        end

        resources :posts
      end
    end

    let(:resolution_post_schema) do
      Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::Resolution::PostSchema'
        end

        adapter do
          pagination do
            default_size 50
          end
        end
      end
    end

    before do
      stub_const('Api::Resolution::PostSchema', resolution_post_schema)
      resolution_api # Trigger let to create API
    end

    it 'schema overrides API, API overrides adapter defaults' do
      schema = Api::Resolution::PostSchema

      # Schema override wins over API
      expect(schema.resolve_option(:pagination, :default_size)).to eq(50)

      # API value when not in schema
      expect(schema.resolve_option(:pagination, :max_size)).to eq(200)

      # Adapter default when not in API or schema
      expect(schema.resolve_option(:pagination, :strategy)).to eq(:offset)
    end

    it 'key_format is at API level' do
      api = Apiwork::API.find('/api/resolution')
      expect(api.key_format).to eq(:camel)
    end
  end

  describe 'Validation' do
    it 'validates key_format enum values' do
      expect do
        Apiwork::API.define '/api/invalid_transform' do
          key_format :invalid_strategy
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'validates type for integer options' do
      expect do
        Apiwork::API.define '/api/invalid_type' do
          adapter do
            pagination do
              default_size 'not_an_integer'
            end
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be integer/)
    end

    it 'raises for unknown options' do
      expect do
        Apiwork::API.define '/api/unknown_option' do
          adapter do
            unknown_option 'value'
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Unknown option/)
    end
  end

  describe 'API adapter method is both getter and DSL' do
    let(:dual_purpose_api) do
      Apiwork::API.define '/api/dual_purpose' do
        key_format :camel

        adapter do
          pagination do
            default_size 30
          end
        end

        resources :posts
      end
    end

    before do
      dual_purpose_api
    end

    it 'returns adapter instance when called without block' do
      api = Apiwork::API.find('/api/dual_purpose')
      expect(api.adapter).to be_a(Apiwork::Adapter::Standard)
    end

    it 'stores adapter config when called with block' do
      api = Apiwork::API.find('/api/dual_purpose')
      expect(api.adapter_config[:pagination][:default_size]).to eq(30)
    end

    it 'stores key_format at API level' do
      api = Apiwork::API.find('/api/dual_purpose')
      expect(api.key_format).to eq(:camel)
    end
  end
end
