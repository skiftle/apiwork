# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract union type unknown field validation' do
  let(:contract_class) do
    create_test_contract do
      type :nested_type do
        param :valid_field, type: :boolean, required: false
        param :another_field, type: :string, required: false
      end

      action :index do
        request do
          body do
            param :custom, type: :union, required: false do
              variant type: :boolean
              variant type: :nested_type
            end
          end
        end
      end
    end
  end

  let(:contract) { contract_class.new }
  let(:action_definition) { contract_class.action_definition(:index) }

  it 'catches unknown fields in union variant (custom type)' do
    result = action_definition.request_definition.body_definition.validate({
                                                                             custom: {
                                                                               invalid_field: true # This should be caught as unknown
                                                                             }
                                                                           })

    expect(result[:issues]).not_to be_empty
    error = result[:issues].first
    expect(error.code).to eq(:field_unknown)
    expect(error.meta[:field]).to eq(:invalid_field)
  end

  it 'allows known fields in union variant (custom type)' do
    result = action_definition.request_definition.body_definition.validate({
                                                                             custom: {
                                                                               valid_field: true,
                                                                               another_field: 'test'
                                                                             }
                                                                           })

    expect(result[:issues]).to be_empty
    expect(result[:params][:custom][:valid_field]).to be(true)
    expect(result[:params][:custom][:another_field]).to eq('test')
  end

  it 'allows boolean variant' do
    result = action_definition.request_definition.body_definition.validate({
                                                                             custom: true
                                                                           })

    expect(result[:issues]).to be_empty
    expect(result[:params][:custom]).to be(true)
  end
end
