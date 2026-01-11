# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection Param Types', type: :integration do
  let(:api_class) { Apiwork::API.find('/api/v1') }
  let(:introspection) { api_class.introspect }

  describe 'Basic param types in TypeScript export' do
    let(:generator) { Apiwork::Export::TypeScript.new('/api/v1') }
    let(:output) { generator.generate }

    it 'exports string types as string' do
      expect(output).to include(': string')
    end

    it 'exports integer types as number' do
      expect(output).to include(': number')
    end

    it 'exports boolean types as boolean' do
      expect(output).to include(': boolean')
    end

    it 'exports datetime types as string' do
      expect(output).to match(/created_at\??: string|createdAt\??: string/)
    end
  end

  describe 'ProfileSchema attributes' do
    it 'has bio as string type' do
      attr = Api::V1::ProfileSchema.attribute_definitions[:bio]
      expect(attr).to be_present
      expect(attr.type).to eq(:string)
    end

    it 'has balance as decimal type' do
      attr = Api::V1::ProfileSchema.attribute_definitions[:balance]
      expect(attr).to be_present
      expect(attr.type).to eq(:decimal)
    end

    it 'has preferred_contact_time as time type' do
      attr = Api::V1::ProfileSchema.attribute_definitions[:preferred_contact_time]
      expect(attr).to be_present
      expect(attr.type).to eq(:time)
    end

    it 'has external_id with uuid format' do
      attr = Api::V1::ProfileSchema.attribute_definitions[:external_id]
      expect(attr).to be_present
      expect(attr.format).to eq(:uuid)
    end

    it 'bio is nullable' do
      attr = Api::V1::ProfileSchema.attribute_definitions[:bio]
      expect(attr.nullable?).to be(true)
    end
  end

  describe 'Param types in OpenAPI export' do
    let(:generator) { Apiwork::Export::OpenAPI.new('/api/v1') }
    let(:spec) { generator.generate }

    it 'generates OpenAPI spec with schemas' do
      expect(spec).to have_key(:components)
      expect(spec[:components]).to have_key(:schemas)
    end

    it 'includes type information in schemas' do
      schemas = spec[:components][:schemas]
      expect(schemas).not_to be_empty
    end
  end
end
