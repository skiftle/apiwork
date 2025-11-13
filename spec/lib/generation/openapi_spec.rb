# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Generation::OpenAPI do
  describe 'default options' do
    it 'has default version 3.1.0' do
      expect(described_class.default_options[:version]).to eq('3.1.0')
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
