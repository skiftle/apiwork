# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schema-based Type Reuse via Imports' do
  # This spec verifies that types are properly imported and reused across contracts
  # instead of being duplicated

  after do
    Apiwork::Contract::Descriptor::TypeStore.clear!
    Apiwork::Contract::Descriptor::EnumStore.clear!
  end

  it 'imports association contracts automatically' do
    # PostContract should automatically import a contract for CommentSchema
    post_contract = Api::V1::PostContract

    # Trigger type generation by accessing the index action
    post_contract.action_definition(:index)

    # Check that PostContract has imported a contract for comments
    expect(post_contract.imports).to have_key(:comment)

    # The imported contract should be associated with CommentSchema
    imported_contract = post_contract.imports[:comment]
    expect(imported_contract.schema_class).to eq(Api::V1::CommentSchema)
  end

  it 'reuses types through imports instead of duplicating' do
    # Trigger type generation by accessing the index action
    Api::V1::PostContract.action_definition(:index)

    # PostContract should have imported CommentContract
    # This enables reuse of filter, sort, and include types instead of duplicating them
    expect(Api::V1::PostContract.imports).to have_key(:comment)

    # The imported contract should have the CommentSchema associated
    imported_contract = Api::V1::PostContract.imports[:comment]
    expect(imported_contract.schema_class).to eq(Api::V1::CommentSchema)
  end
end
