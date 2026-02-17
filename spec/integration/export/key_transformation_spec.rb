# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Key transformation in exports', type: :integration do
  describe 'TypeScript' do
    describe 'with key_format: :keep' do
      let(:generator) { Apiwork::Export::TypeScript.new('/api/v1') }
      let(:output) { generator.generate }

      it 'keeps snake_case property names' do
        expect(output).to match(/created_at: string/)
        expect(output).to match(/updated_at: string/)
      end

      it 'keeps snake_case in filter types' do
        expect(output).to include('created_at')
      end
    end

    describe 'with key_format: :camel' do
      let(:generator) { Apiwork::Export::TypeScript.new('/api/v1', key_format: :camel) }
      let(:output) { generator.generate }

      it 'transforms property names to camelCase' do
        expect(output).to match(/createdAt: string/)
        expect(output).to match(/updatedAt: string/)
      end

      it 'does not contain snake_case for timestamp fields' do
        expect(output).not_to match(/created_at: string/)
        expect(output).not_to match(/updated_at: string/)
      end

      it 'keeps single-word properties unchanged' do
        invoice_interface = extract_interface(output, 'Invoice')

        expect(invoice_interface).to match(/number: string/)
      end

      it 'keeps id property unchanged' do
        expect(output).to match(/\bid: (string|number)/)
      end
    end
  end

  describe 'Zod' do
    describe 'with key_format: :keep' do
      let(:generator) { Apiwork::Export::Zod.new('/api/v1') }
      let(:output) { generator.generate }

      it 'keeps snake_case property names' do
        expect(output).to match(/created_at:/)
        expect(output).to match(/updated_at:/)
      end
    end

    describe 'with key_format: :camel' do
      let(:generator) { Apiwork::Export::Zod.new('/api/v1', key_format: :camel) }
      let(:output) { generator.generate }

      it 'transforms property names to camelCase' do
        expect(output).to match(/createdAt:/)
        expect(output).to match(/updatedAt:/)
      end

      it 'does not contain snake_case for timestamp fields' do
        expect(output).not_to match(/created_at:.*z\./)
        expect(output).not_to match(/updated_at:.*z\./)
      end
    end
  end

  describe 'OpenAPI' do
    describe 'with key_format: :keep' do
      let(:generator) { Apiwork::Export::OpenAPI.new('/api/v1') }
      let(:spec) { generator.generate }

      it 'keeps snake_case property names in schemas' do
        invoice_schema = spec[:components][:schemas]['invoice']
        property_names = invoice_schema[:properties].keys.map(&:to_s)

        expect(property_names).to include('created_at')
        expect(property_names).to include('updated_at')
      end
    end

    describe 'with key_format: :camel' do
      let(:generator) { Apiwork::Export::OpenAPI.new('/api/v1', key_format: :camel) }
      let(:spec) { generator.generate }

      it 'transforms property names to camelCase' do
        invoice_schema = spec[:components][:schemas]['invoice']
        property_names = invoice_schema[:properties].keys.map(&:to_s)

        expect(property_names).to include('createdAt')
        expect(property_names).to include('updatedAt')
      end

      it 'does not contain snake_case for timestamp fields' do
        invoice_schema = spec[:components][:schemas]['invoice']
        property_names = invoice_schema[:properties].keys.map(&:to_s)

        expect(property_names).not_to include('created_at')
        expect(property_names).not_to include('updated_at')
      end
    end
  end

  describe 'V2 API with camelCase default' do
    let(:ts_output) { Apiwork::Export::TypeScript.new('/api/v2').generate }

    it 'uses camelCase by default from API configuration' do
      expect(ts_output).to match(/createdAt: string/)
      expect(ts_output).not_to match(/created_at: string/)
    end
  end

  describe 'consistency across generators' do
    it 'applies same transformation across all generators' do
      ts_output = Apiwork::Export::TypeScript.new('/api/v1', key_format: :camel).generate
      zod_output = Apiwork::Export::Zod.new('/api/v1', key_format: :camel).generate
      openapi_spec = Apiwork::Export::OpenAPI.new('/api/v1', key_format: :camel).generate

      invoice_properties = openapi_spec[:components][:schemas]['invoice'][:properties].keys.map(&:to_s)

      expect(ts_output).to match(/createdAt/)
      expect(zod_output).to match(/createdAt/)
      expect(invoice_properties).to include('createdAt')
    end
  end

  private

  def extract_interface(output, name)
    pattern = /export interface #{name}\s*\{[^}]*\}/m
    match_data = output.match(pattern)
    match_data ? match_data[0] : ''
  end
end
