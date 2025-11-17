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
  end
end
