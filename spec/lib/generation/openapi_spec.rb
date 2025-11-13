# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generation::Generators::OpenAPI do
  describe 'default options' do
    it 'has default version 3.1.0' do
      expect(described_class.default_options[:version]).to eq('3.1.0')
    end
  end

  describe 'version validation' do
    it 'accepts valid version 3.1.0' do
      expect { described_class.new('/api/v1', version: '3.1.0') }.not_to raise_error
    end

    it 'raises error for invalid version' do
      expect do
        described_class.new('/api/v1', version: '3.0.0')
      end.to raise_error(ArgumentError, /Invalid version for openapi: "3.0.0"/)
    end

    it 'raises error for version 2.0' do
      expect do
        described_class.new('/api/v1', version: '2.0')
      end.to raise_error(ArgumentError, /Invalid version for openapi/)
    end

    it 'accepts nil version' do
      expect { described_class.new('/api/v1', version: nil) }.not_to raise_error
    end
  end

  describe 'generator registration' do
    it 'is registered in the registry' do
      expect(Apiwork::Generation::Registry.registered?(:openapi)).to be true
    end

    it 'can be retrieved from the registry' do
      expect(Apiwork::Generation::Registry[:openapi]).to eq(described_class)
    end
  end
end
