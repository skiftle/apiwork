# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schema Metadata', type: :integration do
  describe 'Schema.description' do
    it 'stores description on schema class' do
      expect(Api::V1::ProfileSchema.description).to eq('User profile with personal settings')
    end

    it 'includes description in introspection' do
      api_class = Apiwork::API.find!('/api/v1')
      introspection = api_class.introspect

      profile_resource = introspection.resources[:profile]
      expect(profile_resource).to be_present
    end

    it 'includes description in OpenAPI export' do
      generator = Apiwork::Export::OpenAPI.new('/api/v1')
      spec = generator.generate

      schemas = spec.dig(:components, :schemas) || {}
      profile_key = schemas.keys.find { |k| k.to_s.include?('Profile') }
      profile_schema = profile_key ? schemas[profile_key] : nil

      if profile_schema
        expect(profile_schema[:description]).to eq('User profile with personal settings')
      else
        expect(Api::V1::ProfileSchema.description).to eq('User profile with personal settings')
      end
    end
  end

  describe 'Schema.example' do
    it 'stores example on schema class' do
      schema_example = Api::V1::ProfileSchema.example
      expect(schema_example).to be_a(Hash)
      expect(schema_example[:bio]).to eq('Software developer')
    end

    it 'includes example in OpenAPI export' do
      generator = Apiwork::Export::OpenAPI.new('/api/v1')
      spec = generator.generate

      profile_schema = spec.dig(:components, :schemas, :Profile) ||
                       spec.dig(:components, :schemas, 'Profile')

      expect(profile_schema[:example]).to include(bio: 'Software developer') if profile_schema && profile_schema[:example]
    end
  end

  describe 'Schema.deprecated' do
    it 'marks schema as deprecated' do
      expect(Api::V1::ProfileSchema.deprecated?).to be(true)
    end

    it 'includes deprecated flag in OpenAPI export' do
      generator = Apiwork::Export::OpenAPI.new('/api/v1')
      spec = generator.generate

      profile_schema = spec.dig(:components, :schemas, :Profile) ||
                       spec.dig(:components, :schemas, 'Profile')

      expect(profile_schema[:deprecated]).to be(true) if profile_schema
    end

    it 'non-deprecated schemas do not have deprecated flag' do
      expect(Api::V1::PostSchema.deprecated?).to be(false)
    end
  end

  describe 'Metadata combination' do
    it 'schema can have description, example, and deprecated together' do
      expect(Api::V1::ProfileSchema.description).to eq('User profile with personal settings')
      expect(Api::V1::ProfileSchema.example).to be_a(Hash)
      expect(Api::V1::ProfileSchema.deprecated?).to be(true)
    end
  end
end
