# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Writable context filtering in auto-generated contracts', type: :integration do
  describe 'AuthorContract create vs update payloads' do
    it 'includes only writable: { on: [:create] } attributes in create_payload' do
      create_action = Api::V1::AuthorContract.action_definition(:create)
      serialized = create_action.as_json

      # Input should have nested author param with create_payload type
      expect(serialized[:input]).to have_key(:author)
      expect(serialized[:input][:author][:type]).to eq(:author_create_payload)

      # Get the actual payload type from registry
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
      create_payload = all_types[:author_create_payload]

      # name (writable: true) should be present
      expect(create_payload).to have_key(:name)

      # bio (create-only) should be present
      expect(create_payload).to have_key(:bio)

      # verified (update-only) should NOT be present
      expect(create_payload).not_to have_key(:verified)
    end

    it 'includes only writable: { on: [:update] } attributes in update_payload' do
      update_action = Api::V1::AuthorContract.action_definition(:update)
      serialized = update_action.as_json

      # Input should have nested author param with update_payload type
      expect(serialized[:input]).to have_key(:author)
      expect(serialized[:input][:author][:type]).to eq(:author_update_payload)

      # Get the actual payload type from registry
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
      update_payload = all_types[:author_update_payload]

      # name (writable: true) should be present
      expect(update_payload).to have_key(:name)

      # bio (create-only) should NOT be present
      expect(update_payload).not_to have_key(:bio)

      # verified (update-only) should be present
      expect(update_payload).to have_key(:verified)
    end

    it 'respects writable_for? in attribute definitions' do
      name_attr = Api::V1::AuthorSchema.attribute_definitions[:name]
      bio_attr = Api::V1::AuthorSchema.attribute_definitions[:bio]
      verified_attr = Api::V1::AuthorSchema.attribute_definitions[:verified]

      # name: writable on both
      expect(name_attr.writable_for?(:create)).to be true
      expect(name_attr.writable_for?(:update)).to be true

      # bio: writable on create only
      expect(bio_attr.writable_for?(:create)).to be true
      expect(bio_attr.writable_for?(:update)).to be false

      # verified: writable on update only
      expect(verified_attr.writable_for?(:create)).to be false
      expect(verified_attr.writable_for?(:update)).to be true
    end
  end

  describe 'Type registry includes context-specific payloads' do
    it 'creates separate create_payload and update_payload types' do
      # Force generation
      Api::V1::AuthorContract.action_definition(:create)
      Api::V1::AuthorContract.action_definition(:update)

      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')

      # Keys are symbols in the registry
      expect(all_types).to have_key(:author_create_payload)
      expect(all_types).to have_key(:author_update_payload)
    end

    it 'create_payload excludes update-only fields' do
      Api::V1::AuthorContract.action_definition(:create)

      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
      create_payload = all_types[:author_create_payload]

      expect(create_payload).to have_key(:name)
      expect(create_payload).to have_key(:bio)
      expect(create_payload).not_to have_key(:verified)
    end

    it 'update_payload excludes create-only fields' do
      Api::V1::AuthorContract.action_definition(:update)

      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
      update_payload = all_types[:author_update_payload]

      expect(update_payload).to have_key(:name)
      expect(update_payload).not_to have_key(:bio)
      expect(update_payload).to have_key(:verified)
    end

    it 'includes nullable in introspection' do
      Api::V1::AuthorContract.action_definition(:create)

      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
      create_payload = all_types[:author_create_payload]

      # All fields should have nullable key (even if false)
      expect(create_payload[:name]).to have_key(:nullable)
      expect(create_payload[:bio]).to have_key(:nullable)

      # nullable should match DB constraints
      # (Author fields allow NULL, so they should be nullable: true)
      expect(create_payload[:name][:nullable]).to eq(true)
      expect(create_payload[:bio][:nullable]).to eq(true)
    end
  end
end
