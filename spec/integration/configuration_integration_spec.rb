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
    let(:config_test_api) do
      Apiwork::API.draw '/api/config_test' do
        configure do
          output_key_format :camel
          input_key_format :underscore
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

    it 'applies API configuration to schema methods' do
      schema_class = Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::ConfigTest::PostSchema'
        end
      end

      # Should use API configuration
      expect(schema_class.output_key_format).to eq(:camel)
      expect(schema_class.input_key_format).to eq(:underscore)
      expect(schema_class.default_page_size).to eq(25)
      expect(schema_class.max_page_size).to eq(100)
      expect(schema_class.default_sort).to eq(title: :asc)
    end
  end

  describe 'Schema-level configuration override' do
    let(:schema_override_api) do
      Apiwork::API.draw '/api/schema_override' do
        configure do
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

        configure do
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

    it 'schema configuration overrides API configuration' do
      # Schema overrides should win
      expect(schema_with_config.default_page_size).to eq(50)
      expect(schema_with_config.max_page_size).to eq(150)

      # Non-overridden values should inherit from API
      expect(schema_with_config.default_sort).to eq(id: :asc)
    end
  end

  describe 'Configuration inheritance chain' do
    let(:inheritance_api) do
      Apiwork::API.draw '/api/inheritance' do
        configure do
          output_key_format :camel
          default_page_size 20
          max_page_size 200
          default_sort id: :asc
          max_array_items 1000
        end

        resources :posts
      end
    end

    let(:inheritance_schema) do
      Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::Inheritance::PostSchema'
        end

        configure do
          default_page_size 50
        end
      end
    end

    let(:inheritance_contract) do
      schema_class = inheritance_schema # Capture for closure
      Class.new(Apiwork::Contract::Base) do
        def self.name
          'Api::Inheritance::PostContract'
        end

        schema schema_class

        configure do
          max_array_items 500
        end

        action :create do
          request do
            body do
              param :title, type: :string
              param :tags, type: :array, of: :string
            end
          end
        end
      end
    end

    before do
      inheritance_api      # Trigger let to create API
      inheritance_schema   # Trigger let to create Schema
      inheritance_contract # Trigger let to create Contract
    end

    after do
      Apiwork::API::Registry.unregister('/api/inheritance')
    end

    it 'contract configuration overrides schema and API configuration' do
      # Contract override wins
      expect(Apiwork::Configuration::Resolver.resolve(
               :max_array_items,
               contract_class: inheritance_contract,
               schema_class: inheritance_schema,
               api_class: inheritance_api
             )).to eq(500)

      # Schema override wins over API
      expect(Apiwork::Configuration::Resolver.resolve(
               :default_page_size,
               contract_class: inheritance_contract,
               schema_class: inheritance_schema,
               api_class: inheritance_api
             )).to eq(50)

      # API value when no overrides
      expect(Apiwork::Configuration::Resolver.resolve(
               :output_key_format,
               contract_class: inheritance_contract,
               schema_class: inheritance_schema,
               api_class: inheritance_api
             )).to eq(:camel)
    end
  end

  describe 'Deep merge for hash settings' do
    let(:deep_merge_api) do
      Apiwork::API.draw '/api/deep_merge' do
        configure do
          default_sort id: :asc, created_at: :desc
        end

        resources :posts
      end
    end

    let(:deep_merge_schema) do
      Class.new(Apiwork::Schema::Base) do
        def self.name
          'Api::DeepMerge::PostSchema'
        end

        configure do
          default_sort title: :asc
        end
      end
    end

    before do
      deep_merge_api    # Trigger let to create API
      deep_merge_schema # Trigger let to create Schema
    end

    after do
      Apiwork::API::Registry.unregister('/api/deep_merge')
    end

    it 'deep merges hash configuration values' do
      # Should merge API and Schema default_sort
      result = Apiwork::Configuration::Resolver.resolve(
        :default_sort,
        schema_class: deep_merge_schema,
        api_class: deep_merge_api
      )

      # Schema value should win for 'title', API values should be included
      expect(result).to include(title: :asc)
      expect(result).to include(id: :asc)
      expect(result).to include(created_at: :desc)
    end
  end

  describe 'Validation' do
    it 'validates output_key_format values' do
      expect do
        Apiwork::API.draw '/api/invalid_transform' do
          configure do
            output_key_format :invalid_strategy
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Invalid output_key_format/)
    end

    it 'validates input_key_format values' do
      expect do
        Apiwork::API.draw '/api/invalid_deserialize' do
          configure do
            input_key_format :invalid_strategy
          end
        end
      end.to raise_error(Apiwork::ConfigurationError, /Invalid input_key_format/)
    end
  end
end
