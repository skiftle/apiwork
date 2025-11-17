# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Introspection for association-only schemas', type: :request do
  # Force reload of API configuration before tests
  before(:all) do
    load Rails.root.join('config/apis/v1.rb')
  end

  describe 'Base types for association-only schemas' do
    it 'includes base types for schemas that exist only as associations' do
      introspection = Apiwork.introspect('/api/v1')

      # Reply schema exists only as nested association (no standalone route)
      # It should still have its base type in introspection
      expect(introspection[:types]).to have_key(:reply)

      # Verify the reply type has expected attributes
      reply_type = introspection[:types][:reply]
      expect(reply_type).to have_key(:content)
      expect(reply_type).to have_key(:author)
      expect(reply_type).to have_key(:created_at)
      expect(reply_type).to have_key(:updated_at)

      # Also verify filter/sort types exist (these already worked before)
      expect(introspection[:types]).to have_key(:reply_filter)
      expect(introspection[:types]).to have_key(:reply_sort)
    end

    it 'includes nested_payload union for schemas with writable associations' do
      introspection = Apiwork.introspect('/api/v1')

      # Comment has writable replies association, so it should have nested_payload
      expect(introspection[:types]).to have_key(:comment_nested_payload)

      # The nested payload should be a union with create and update variants
      nested_payload = introspection[:types][:comment_nested_payload]
      expect(nested_payload).to be_a(Hash)
      expect(nested_payload).to have_key(:discriminator)
      expect(nested_payload[:discriminator]).to eq(:_type)
    end

    it 'includes nested_payload for schemas USED as writable associations' do
      introspection = Apiwork.introspect('/api/v1')

      # Comment is used as writable association in Post
      # Comment has writable attributes/associations → gets nested_payload
      expect(introspection[:types]).to have_key(:comment_nested_payload)

      # Reply is used as writable association in Comment
      # Reply has writable attributes → gets nested_payload
      expect(introspection[:types]).to have_key(:reply_nested_payload)
    end

    it 'does NOT include nested_payload for schemas NOT used as writable associations' do
      introspection = Apiwork.introspect('/api/v1')

      # User has writable attributes but is not used as writable association
      expect(introspection[:types]).not_to have_key(:user_nested_payload)

      # Article has associations but none are writable, not used as nested
      expect(introspection[:types]).not_to have_key(:article_nested_payload)

      # Author has no writable attributes or associations, not used as nested
      expect(introspection[:types]).not_to have_key(:author_nested_payload)
    end
  end
end
