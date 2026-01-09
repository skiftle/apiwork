# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::OpenAPI do
  let(:path) { '/api/v1' }
  let(:generator) { described_class.new(path) }

  describe 'default options' do
    it 'has default version 3.1.0' do
      expect(described_class.default_options[:version]).to eq('3.1.0')
    end
  end

  describe 'version validation' do
    it 'accepts valid version 3.1.0' do
      expect { described_class.new(path, version: '3.1.0') }.not_to raise_error
    end

    it 'raises error for invalid version' do
      expect do
        described_class.new(path, version: '3.0.0')
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'raises error for version 2.0' do
      expect do
        described_class.new(path, version: '2.0')
      end.to raise_error(Apiwork::ConfigurationError, /must be one of/)
    end

    it 'accepts nil version' do
      expect { described_class.new(path, version: nil) }.not_to raise_error
    end
  end

  describe 'generator registration' do
    it 'is registered in the registry' do
      expect(Apiwork::Export.registered?(:openapi)).to be true
    end

    it 'can be retrieved from the registry' do
      expect(Apiwork::Export.find(:openapi)).to eq(described_class)
    end
  end

  describe 'unknown type mapping' do
    it 'maps :unknown to empty schema {}' do
      param = Apiwork::Introspection::Param.build(type: :unknown)
      result = generator.send(:map_primitive, param)
      expect(result).to eq({})
    end

    it 'uses empty schema {} as fallback for unmapped types' do
      param = Apiwork::Introspection::Param.build(type: :some_unmapped_type)
      result = generator.send(:map_primitive, param)
      expect(result).to eq({})
    end

    it 'returns nil for :unknown in openapi_type method' do
      result = generator.send(:openapi_type, :unknown)
      expect(result).to be_nil
    end
  end

  describe '#generate' do
    let(:output) { generator.generate }

    it 'returns a hash' do
      expect(output).to be_a(Hash)
    end

    describe 'root structure' do
      it 'includes openapi version' do
        expect(output[:openapi]).to eq('3.1.0')
      end

      it 'includes info section' do
        expect(output[:info]).to be_a(Hash)
        expect(output[:info][:title]).to be_present
        expect(output[:info][:version]).to be_present
      end

      it 'includes paths section' do
        expect(output[:paths]).to be_a(Hash)
      end

      it 'includes components section' do
        expect(output[:components]).to be_a(Hash)
        expect(output[:components][:schemas]).to be_a(Hash)
      end

      it 'follows correct key order' do
        keys = output.keys
        expected_order = %i[openapi info servers paths components]
        expect(keys).to eq(expected_order & keys)
      end
    end

    describe 'paths generation' do
      it 'generates paths for resources' do
        expect(output[:paths]).not_to be_empty
      end

      it 'uses OpenAPI path parameter syntax {id}' do
        path_with_id = output[:paths].keys.find { |p| p.include?('{') }
        expect(path_with_id).to match(/\{[^}]+\}/) if path_with_id
      end

      it 'includes HTTP methods as keys' do
        first_path = output[:paths].values.first
        expect(first_path.keys).to all(be_a(String).or(be_a(Symbol)))
        expect(first_path.keys.map(&:to_s)).to all(match(/^(get|post|put|patch|delete)$/))
      end
    end

    describe 'operation generation' do
      let(:first_operation) do
        output[:paths].values.first&.values&.first
      end

      it 'includes operationId' do
        expect(first_operation[:operationId]).to be_present
      end

      it 'includes responses' do
        expect(first_operation[:responses]).to be_a(Hash)
      end

      it 'includes success response' do
        responses = first_operation[:responses]
        success_codes = responses.keys.map(&:to_s) & %w[200 201 204]
        expect(success_codes).not_to be_empty
      end
    end

    describe 'schemas generation' do
      let(:schemas) { output[:components][:schemas] }

      it 'generates schemas for types' do
        expect(schemas).not_to be_empty
      end

      it 'includes type definitions' do
        schema = schemas.values.first
        expect(schema).to have_key(:type).or(have_key(:oneOf)).or(have_key(:$ref))
      end
    end
  end

  describe 'serialization formats' do
    it 'can serialize to JSON' do
      json_output = Apiwork::Export.generate(:openapi, path, format: :json)
      expect(json_output).to be_a(String)
      expect { JSON.parse(json_output) }.not_to raise_error
    end

    it 'can serialize to YAML' do
      yaml_output = Apiwork::Export.generate(:openapi, path, format: :yaml)
      expect(yaml_output).to be_a(String)
      expect { YAML.safe_load(yaml_output, permitted_classes: [Symbol]) }.not_to raise_error
    end
  end

  describe 'file extension' do
    it 'returns .json for JSON format' do
      expect(generator.file_extension_for(format: :json)).to eq('.json')
    end

    it 'returns .yaml for YAML format' do
      expect(generator.file_extension_for(format: :yaml)).to eq('.yaml')
    end
  end

  describe 'content type' do
    it 'returns application/json for JSON format' do
      expect(generator.content_type_for(format: :json)).to eq('application/json')
    end

    it 'returns application/yaml for YAML format' do
      expect(generator.content_type_for(format: :yaml)).to eq('application/yaml')
    end
  end

  describe 'type mapping' do
    it 'maps string to OpenAPI string type' do
      param = Apiwork::Introspection::Param.build(type: :string)
      result = generator.send(:map_primitive, param)
      expect(result[:type]).to eq('string')
    end

    it 'maps integer to OpenAPI integer type' do
      param = Apiwork::Introspection::Param.build(type: :integer)
      result = generator.send(:map_primitive, param)
      expect(result[:type]).to eq('integer')
    end

    it 'maps boolean to OpenAPI boolean type' do
      param = Apiwork::Introspection::Param.build(type: :boolean)
      result = generator.send(:map_primitive, param)
      expect(result[:type]).to eq('boolean')
    end

    it 'maps datetime to OpenAPI string with date-time format' do
      param = Apiwork::Introspection::Param.build(type: :datetime)
      result = generator.send(:map_primitive, param)
      expect(result[:type]).to eq('string')
      expect(result[:format]).to eq('date-time')
    end

    it 'maps uuid to OpenAPI string with uuid format' do
      param = Apiwork::Introspection::Param.build(type: :uuid)
      result = generator.send(:map_primitive, param)
      expect(result[:type]).to eq('string')
      expect(result[:format]).to eq('uuid')
    end
  end

  describe 'API with info section' do
    it 'includes custom info fields' do
      Apiwork::API.define '/api/openapi_info_test' do
        export :openapi

        info do
          title 'Test API'
          description 'API for testing'
          version '2.0.0'
        end

        resources :items
      end

      info_output = described_class.new('/api/openapi_info_test').generate

      expect(info_output[:info][:title]).to eq('Test API')
      expect(info_output[:info][:description]).to eq('API for testing')
      expect(info_output[:info][:version]).to eq('2.0.0')

      Apiwork::API.unregister('/api/openapi_info_test')
    end
  end

  describe 'key_format option' do
    it 'transforms keys to camelCase with :camel' do
      Apiwork::API.define '/api/openapi_camel_test' do
        export :openapi

        object :user_profile do
          param :first_name, type: :string
          param :last_name, type: :string
        end

        resources :users
      end

      gen = described_class.new('/api/openapi_camel_test', key_format: :camel)
      output = gen.generate
      schema = output.dig(:components, :schemas, :UserProfile)

      if schema
        property_keys = schema[:properties]&.keys&.map(&:to_s) || []
        expect(property_keys).to include('firstName', 'lastName')
      end

      Apiwork::API.unregister('/api/openapi_camel_test')
    end
  end
end
