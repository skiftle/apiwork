# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Configuration Integration', type: :request do
  # Test configuration features using ONLY public APIs and runtime behavior
  # The public API is: configure blocks in API, Schema, Contract

  # Force reload of API configuration before tests
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'API-level configuration' do
    before(:all) do
      @config_test_api = Apiwork::API.draw '/api/config_test' do
        configure do
          serialize_key_transform :camelize_lower
          deserialize_key_transform :underscore
          default_page_size 25
          maximum_page_size 100
          default_sort title: :asc
          max_array_items 500
        end

        resources :posts
      end
    end

    after(:all) do
      Apiwork::API::Registry.instance_variable_get(:@apis).delete('/api/config_test')
    end

    it 'applies API configuration to schema methods' do
      schema_class = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::ConfigTest::PostSchema'
        end
      end

      # Should use API configuration
      expect(schema_class.serialize_key_transform).to eq(:camelize_lower)
      expect(schema_class.deserialize_key_transform).to eq(:underscore)
      expect(schema_class.default_page_size).to eq(25)
      expect(schema_class.maximum_page_size).to eq(100)
      expect(schema_class.default_sort).to eq(title: :asc)
    end
  end

  describe 'Schema-level configuration override' do
    before(:all) do
      @schema_override_api = Apiwork::API.draw '/api/schema_override' do
        configure do
          default_page_size 20
          maximum_page_size 200
          default_sort id: :asc
        end

        resources :posts
      end

      @schema_with_config = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::SchemaOverride::PostSchema'
        end

        configure do
          default_page_size 50
          maximum_page_size 150
        end
      end
    end

    after(:all) do
      Apiwork::API::Registry.instance_variable_get(:@apis).delete('/api/schema_override')
    end

    it 'schema configuration overrides API configuration' do
      # Schema overrides should win
      expect(@schema_with_config.default_page_size).to eq(50)
      expect(@schema_with_config.maximum_page_size).to eq(150)

      # Non-overridden values should inherit from API
      expect(@schema_with_config.default_sort).to eq(id: :asc)
    end
  end

  describe 'Configuration inheritance chain' do
    before(:all) do
      @inheritance_api = Apiwork::API.draw '/api/inheritance' do
        configure do
          serialize_key_transform :camelize_lower
          default_page_size 20
          maximum_page_size 200
          default_sort id: :asc
          max_array_items 1000
        end

        resources :posts
      end

      # Create schema first
      @inheritance_schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::Inheritance::PostSchema'
        end

        configure do
          default_page_size 50
        end
      end

      # Create contract referencing the schema
      inheritance_schema = @inheritance_schema # Capture for closure
      @inheritance_contract = Class.new(Apiwork::Contract::Base) do
        def self.name
          'Api::Inheritance::PostContract'
        end

        schema inheritance_schema

        configure do
          max_array_items 500
        end

        action :create do
          input do
            param :title, type: :string
            param :tags, type: [:string]
          end
        end
      end
    end

    after(:all) do
      Apiwork::API::Registry.instance_variable_get(:@apis).delete('/api/inheritance')
    end

    it 'contract configuration overrides schema and API configuration' do
      # Contract override wins
      expect(Apiwork::Configuration::Resolver.resolve(
               :max_array_items,
               contract_class: @inheritance_contract,
               schema_class: @inheritance_schema,
               api_class: @inheritance_api
             )).to eq(500)

      # Schema override wins over API
      expect(Apiwork::Configuration::Resolver.resolve(
               :default_page_size,
               contract_class: @inheritance_contract,
               schema_class: @inheritance_schema,
               api_class: @inheritance_api
             )).to eq(50)

      # API value when no overrides
      expect(Apiwork::Configuration::Resolver.resolve(
               :serialize_key_transform,
               contract_class: @inheritance_contract,
               schema_class: @inheritance_schema,
               api_class: @inheritance_api
             )).to eq(:camelize_lower)
    end
  end

  describe 'Deep merge for hash settings' do
    before(:all) do
      @deep_merge_api = Apiwork::API.draw '/api/deep_merge' do
        configure do
          default_sort id: :asc, created_at: :desc
        end

        resources :posts
      end

      @deep_merge_schema = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::DeepMerge::PostSchema'
        end

        configure do
          default_sort title: :asc
        end
      end
    end

    after(:all) do
      Apiwork::API::Registry.instance_variable_get(:@apis).delete('/api/deep_merge')
    end

    it 'deep merges hash configuration values' do
      # Should merge API and Schema default_sort
      result = Apiwork::Configuration::Resolver.resolve(
        :default_sort,
        schema_class: @deep_merge_schema,
        api_class: @deep_merge_api
      )

      # Schema value should win for 'title', API values should be included
      expect(result).to include(title: :asc)
      expect(result).to include(id: :asc)
      expect(result).to include(created_at: :desc)
    end
  end

  describe 'Validation' do
    it 'validates serialize_key_transform values' do
      expect do
        Apiwork::API.draw '/api/invalid_transform' do
          configure do
            serialize_key_transform :invalid_strategy
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Invalid serialize_key_transform/)
    end

    it 'validates deserialize_key_transform values' do
      expect do
        Apiwork::API.draw '/api/invalid_deserialize' do
          configure do
            deserialize_key_transform :invalid_strategy
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Invalid deserialize_key_transform/)
    end
  end
end
