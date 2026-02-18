# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Key format across exports', type: :integration do
  describe 'TypeScript with V2 camelCase' do
    let(:output) { Apiwork::Export::TypeScript.new('/api/v2').generate }

    it 'generates camelCase property names' do
      expect(output).to match(/createdAt: string/)
    end

    it 'excludes snake_case timestamp fields' do
      expect(output).not_to match(/created_at: string/)
    end
  end

  describe 'OpenAPI with V2 camelCase' do
    let(:spec) { Apiwork::Export::OpenAPI.new('/api/v2').generate }

    it 'generates camelCase property names in schemas' do
      schema = spec[:components][:schemas].values.first
      property_names = schema[:properties].keys.map(&:to_s)

      expect(property_names).to include('createdAt')
    end

    it 'excludes snake_case timestamp fields' do
      schema = spec[:components][:schemas].values.first
      property_names = schema[:properties].keys.map(&:to_s)

      expect(property_names).not_to include('created_at')
    end
  end

  describe 'Consistency across generators' do
    it 'generates camelCase keys in TypeScript' do
      output = Apiwork::Export::TypeScript.new('/api/v1', key_format: :camel).generate

      expect(output).to match(/createdAt/)
    end

    it 'generates camelCase keys in OpenAPI' do
      spec = Apiwork::Export::OpenAPI.new('/api/v1', key_format: :camel).generate
      invoice_properties = spec[:components][:schemas]['invoice'][:properties].keys.map(&:to_s)

      expect(invoice_properties).to include('createdAt')
    end
  end

  context 'with default key_format :keep' do
    it 'keeps snake_case in TypeScript' do
      output = Apiwork::Export::TypeScript.new('/api/v1').generate

      expect(output).to match(/created_at: string/)
    end

    it 'keeps snake_case in OpenAPI' do
      spec = Apiwork::Export::OpenAPI.new('/api/v1').generate
      invoice_properties = spec[:components][:schemas]['invoice'][:properties].keys.map(&:to_s)

      expect(invoice_properties).to include('created_at')
    end
  end
end
