# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection do
  before do
    Apiwork.reset!
    load File.expand_path('../dummy/config/apis/v1.rb', __dir__)
  end

  describe 'global type qualification' do
    it 'does not qualify global filter types in introspect output' do
      api = Apiwork::API::Registry.find('/api/v1')
      introspect = api.introspect

      # Check post_filter type has string_filter as a variant (not post_string_filter)
      post_filter = introspect[:types][:post_filter]
      expect(post_filter).to be_present

      # Check title field has union with string and string_filter variants
      title_field = post_filter[:shape][:title]
      expect(title_field).to be_present
      expect(title_field[:type]).to eq(:union)
      expect(title_field[:variants]).to be_an(Array)

      # Variant 0 should be primitive string
      # Variant 1 should be :string_filter (NOT :post_string_filter)
      variant_types = title_field[:variants].map { |v| v[:type] }
      expect(variant_types).to include(:string)
      expect(variant_types).to include(:string_filter)
      expect(variant_types).not_to include(:post_string_filter)
    end

    it 'does not qualify global filter types in Zod output' do
      generator = Apiwork::Spec::Zod.new('/api/v1')
      output = generator.generate

      # Should reference StringFilterSchema, not PostStringFilterSchema
      expect(output).to include('StringFilterSchema')
      expect(output).not_to include('PostStringFilterSchema')

      # Should not have duplicate unions like z.union([z.string(), z.string()])
      # This would happen if both variants map to the same primitive
      expect(output).not_to match(/z\.union\(\[z\.string\(\), z\.string\(\)\]\)/)
    end

    it 'does not qualify other global types like datetime_filter' do
      api = Apiwork::API::Registry.find('/api/v1')
      introspect = api.introspect

      post_filter = introspect[:types][:post_filter]
      updated_at_field = post_filter[:shape][:updated_at]

      expect(updated_at_field).to be_present
      variant_types = updated_at_field[:variants].map { |v| v[:type] }
      expect(variant_types).to include(:datetime_filter)
      expect(variant_types).not_to include(:post_datetime_filter)
    end

    it 'still qualifies contract-scoped custom types' do
      api = Apiwork::API::Registry.find('/api/v1')
      introspect = api.introspect

      # post_filter itself should still be qualified as post_filter (not just filter)
      expect(introspect[:types]).to have_key(:post_filter)
      expect(introspect[:types]).not_to have_key(:filter)
    end
  end
end
