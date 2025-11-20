# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection for association-only schemas', type: :request do
  # Force reload of API configuration before tests
  before(:all) do
    # Clear all caches first
    Apiwork::Contract::SchemaRegistry.clear!
    Apiwork::Contract::Descriptor::Registry.clear!
    api = Apiwork::API.find('/api/v1')
    api&.instance_variable_set(:@introspect, nil)

    # Load all contracts explicitly before reloading API config
    # This ensures they're available when SchemaRegistry tries to find them
    # (We removed anonymous contract creation, so contracts must exist)
    Dir.glob(Rails.root.join('app/contracts/api/v1/*_contract.rb')).each do |contract_file|
      load contract_file
    end

    # Load all schemas including STI variants to register them
    Dir.glob(Rails.root.join('app/schemas/api/v1/*_schema.rb')).each do |schema_file|
      load schema_file
    end

    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'Base types for association-only schemas' do
    it 'includes base types for schemas that exist only as associations' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Reply schema exists only as nested association (no standalone route)
      # It should still have its base type in introspection
      expect(introspection[:types]).to have_key(:reply)

      # Verify the reply type has expected attributes
      reply_type = introspection[:types][:reply]
      expect(reply_type[:type]).to eq(:object)
      expect(reply_type[:shape]).to have_key(:content)
      expect(reply_type[:shape]).to have_key(:author)
      expect(reply_type[:shape]).to have_key(:created_at)
      expect(reply_type[:shape]).to have_key(:updated_at)

      # Also verify filter/sort types exist (these already worked before)
      expect(introspection[:types]).to have_key(:reply_filter)
      expect(introspection[:types]).to have_key(:reply_sort)
    end

    it 'includes nested_payload union for schemas with writable associations' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Comment has writable replies association, so it should have nested_payload types
      expect(introspection[:types]).to have_key(:comment_nested_create_payload)
      expect(introspection[:types]).to have_key(:comment_nested_update_payload)
      expect(introspection[:types]).to have_key(:comment_nested_payload)

      # The nested_payload should be a discriminated union
      nested_payload = introspection[:types][:comment_nested_payload]
      expect(nested_payload).to be_a(Hash)
      expect(nested_payload).to have_key(:discriminator)
      expect(nested_payload[:discriminator]).to eq(:_type)

      # The union should have two variants that reference the separate types
      expect(nested_payload[:variants]).to be_an(Array)
      expect(nested_payload[:variants].size).to eq(2)

      # Variants should reference the separate create/update types (using qualified names)
      create_variant = nested_payload[:variants].find { |v| v[:tag] == 'create' }
      update_variant = nested_payload[:variants].find { |v| v[:tag] == 'update' }

      expect(create_variant[:type]).to eq(:comment_nested_create_payload)
      expect(update_variant[:type]).to eq(:comment_nested_update_payload)
    end

    it 'includes nested_payload for schemas USED as writable associations' do
      introspection = Apiwork::API.introspect('/api/v1')

      # Comment is used as writable association in Post
      # Should have all three types: create, update, and union
      expect(introspection[:types]).to have_key(:comment_nested_create_payload)
      expect(introspection[:types]).to have_key(:comment_nested_update_payload)
      expect(introspection[:types]).to have_key(:comment_nested_payload)

      # Reply is used as writable association in Comment
      # Should have all three types: create, update, and union
      expect(introspection[:types]).to have_key(:reply_nested_create_payload)
      expect(introspection[:types]).to have_key(:reply_nested_update_payload)
      expect(introspection[:types]).to have_key(:reply_nested_payload)
    end

    it 'does NOT include nested_payload for schemas NOT used as writable associations' do
      introspection = Apiwork::API.introspect('/api/v1')

      # User has writable attributes but is not used as writable association
      # Should not have any of the three nested_payload types
      expect(introspection[:types]).not_to have_key(:user_nested_create_payload)
      expect(introspection[:types]).not_to have_key(:user_nested_update_payload)
      expect(introspection[:types]).not_to have_key(:user_nested_payload)

      # Article has associations but none are writable, not used as nested
      expect(introspection[:types]).not_to have_key(:article_nested_create_payload)
      expect(introspection[:types]).not_to have_key(:article_nested_update_payload)
      expect(introspection[:types]).not_to have_key(:article_nested_payload)

      # Author has no writable attributes or associations, not used as nested
      expect(introspection[:types]).not_to have_key(:author_nested_create_payload)
      expect(introspection[:types]).not_to have_key(:author_nested_update_payload)
      expect(introspection[:types]).not_to have_key(:author_nested_payload)
    end
  end
end
