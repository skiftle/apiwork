# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schema-based Type Reuse via Imports' do
  # This spec verifies that types are properly imported and reused across contracts
  # instead of being duplicated

  after(:each) do
    Apiwork::Contract::Descriptors::TypeStore.clear_local!
    Apiwork::Contract::Descriptors::EnumStore.clear_local!
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

  it 'references imported filter types' do
    post_contract = Api::V1::PostContract
    action_def = post_contract.action_definition(:index)

    # The comments filter should reference the imported :comment_filter type
    # instead of creating a duplicate type in PostContract
    expect(post_contract.imports).to have_key(:comment)
  end

  it 'references imported sort types' do
    post_contract = Api::V1::PostContract
    action_def = post_contract.action_definition(:index)

    # The comments sort should reference the imported :comment_sort type
    expect(post_contract.imports).to have_key(:comment)
  end
end
