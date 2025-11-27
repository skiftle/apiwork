# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adapter Configuration Integration', type: :request do
  # Test adapter configuration features using ONLY public APIs and runtime behavior
  # The public API is: adapter blocks in API and Schema with resolve_option

  # Force reload of API configuration before tests
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'API-level adapter configuration' do
    let(:config_test_api) do
      Apiwork::API.draw '/api/config_test' do
        adapter do
          key_format :camel
          default_page_size 25
          max_page_size 100
          default_sort title: :asc
          max_array_items 500
        end

        resources :posts
      end
    end

    before do
      config_test_api # Trigger let to create API
    end

    after do
      Apiwork::API::Registry.unregister('/api/config_test')
    end

    it 'applies API configuration via schema resolve_option' do
      schema_class = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::ConfigTest::PostSchema'
        end
      end

      # Should use API configuration via resolve_option
      expect(schema_class.resolve_option(:default_page_size)).to eq(25)
      expect(schema_class.resolve_option(:max_page_size)).to eq(100)
      expect(schema_class.resolve_option(:default_sort)).to eq(title: :asc)
    end
  end

  describe 'Schema-level adapter configuration override' do
    let(:schema_override_api) do
      Apiwork::API.draw '/api/schema_override' do
        adapter do
          default_page_size 20
          max_page_size 200
          default_sort id: :asc
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
          default_page_size 50
          max_page_size 150
        end
      end
    end

    before do
      schema_override_api # Trigger let to create API
      schema_with_config  # Trigger let to create Schema
    end

    after do
      Apiwork::API::Registry.unregister('/api/schema_override')
    end

    it 'schema adapter configuration overrides API adapter configuration' do
      # Schema overrides should win
      expect(schema_with_config.resolve_option(:default_page_size)).to eq(50)
      expect(schema_with_config.resolve_option(:max_page_size)).to eq(150)

      # Non-overridden values should inherit from API
      expect(schema_with_config.resolve_option(:default_sort)).to eq(id: :asc)
    end
  end

  describe 'Resolution chain: Schema -> API -> Adapter default' do
    let(:resolution_api) do
      Apiwork::API.draw '/api/resolution' do
        adapter do
          key_format :camel
          default_page_size 20
          max_page_size 200
        end

        resources :posts
      end
    end

    before(:all) do
      module Api
        module Resolution
          class PostSchema < Apiwork::Schema::Base
            adapter do
              default_page_size 50
            end
          end
        end
      end
    end

    after(:all) do
      Api::Resolution.send(:remove_const, :PostSchema) if defined?(Api::Resolution::PostSchema)
    end

    before do
      resolution_api # Trigger let to create API
    end

    after do
      Apiwork::API::Registry.unregister('/api/resolution')
    end

    it 'schema overrides API, API overrides adapter defaults' do
      schema = Api::Resolution::PostSchema

      # Schema override wins over API
      expect(schema.resolve_option(:default_page_size)).to eq(50)

      # API value when not in schema
      expect(schema.resolve_option(:key_format)).to eq(:camel)
      expect(schema.resolve_option(:max_page_size)).to eq(200)

      # Adapter default when not in API or schema
      expect(schema.resolve_option(:max_array_items)).to eq(1000)
    end
  end

  describe 'No deep merge - schema replaces API value entirely' do
    let(:no_merge_api) do
      Apiwork::API.draw '/api/no_merge' do
        adapter do
          default_sort id: :asc, created_at: :desc
        end

        resources :posts
      end
    end

    let(:no_merge_schema) do
      Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::NoMerge::PostSchema'
        end

        adapter do
          default_sort title: :asc
        end
      end
    end

    before do
      no_merge_api    # Trigger let to create API
      no_merge_schema # Trigger let to create Schema
    end

    after do
      Apiwork::API::Registry.unregister('/api/no_merge')
    end

    it 'does NOT deep merge - schema value completely replaces API value' do
      # Schema value should completely replace, NOT merge
      result = no_merge_schema.resolve_option(:default_sort)

      expect(result).to eq(title: :asc)
      expect(result).not_to include(:id)
      expect(result).not_to include(:created_at)
    end
  end

  describe 'Validation' do
    it 'validates key_format enum values' do
      expect do
        Apiwork::API.draw '/api/invalid_transform' do
          adapter do
            key_format :invalid_strategy
          end
        end
      end.to raise_error(Apiwork::AdapterError, /must be one of/)
    end

    it 'validates type for integer options' do
      expect do
        Apiwork::API.draw '/api/invalid_type' do
          adapter do
            default_page_size 'not_an_integer'
          end
        end
      end.to raise_error(Apiwork::AdapterError, /must be integer/)
    end

    it 'raises for unknown options' do
      expect do
        Apiwork::API.draw '/api/unknown_option' do
          adapter do
            unknown_option 'value'
          end
        end
      end.to raise_error(Apiwork::AdapterError, /Unknown option/)
    end
  end

  describe 'API adapter method is both getter and DSL' do
    let(:dual_purpose_api) do
      Apiwork::API.draw '/api/dual_purpose' do
        adapter do
          key_format :camel
        end

        resources :posts
      end
    end

    before do
      dual_purpose_api
    end

    after do
      Apiwork::API::Registry.unregister('/api/dual_purpose')
    end

    it 'returns adapter instance when called without block' do
      api = Apiwork::API.find('/api/dual_purpose')
      expect(api.adapter).to be_a(Apiwork::Adapter::Apiwork)
    end

    it 'stores config when called with block' do
      api = Apiwork::API.find('/api/dual_purpose')
      expect(api.adapter_config[:key_format]).to eq(:camel)
    end
  end
end
