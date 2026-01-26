# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representation-based Type Reuse via Imports' do
  it 'imports association contracts automatically' do
    post_contract = Api::V1::PostContract

    post_contract.action_for(:index)

    expect(post_contract.imports).to have_key(:comment)

    imported_contract = post_contract.imports[:comment]
    expect(imported_contract.representation_class).to eq(Api::V1::CommentRepresentation)
  end

  it 'reuses types through imports instead of duplicating' do
    Api::V1::PostContract.action_for(:index)

    expect(Api::V1::PostContract.imports).to have_key(:comment)

    imported_contract = Api::V1::PostContract.imports[:comment]
    expect(imported_contract.representation_class).to eq(Api::V1::CommentRepresentation)
  end
end
