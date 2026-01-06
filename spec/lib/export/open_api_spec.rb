# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::OpenAPI do
  before do
    load File.expand_path('../../dummy/config/apis/v1.rb', __dir__)
  end

  let(:path) { '/api/v1' }

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
    let(:generator) { described_class.new(path) }

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
end
