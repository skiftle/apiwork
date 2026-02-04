# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract custom type unknown field validation' do
  let(:contract_class) do
    create_test_contract do
      object :my_custom_type do
        boolean :valid_field, optional: true
        string :another_field, optional: true
      end

      action :index do
        request do
          body do
            reference :custom, optional: true, to: :my_custom_type
          end
        end
      end
    end
  end

  let(:contract) { contract_class.new }
  let(:action) { contract_class.action_for(:index) }
  let(:definition) { action.request.body }

  it 'catches unknown fields in custom types' do
    result = definition.validate(
      {
        custom: {
          invalid_field: true,
        },
      },
    )

    expect(result[:issues]).not_to be_empty
    error = result[:issues].first
    expect(error.code).to eq(:field_unknown)
    expect(error.meta[:field]).to eq(:invalid_field)
  end

  it 'allows known fields in custom types' do
    result = definition.validate(
      {
        custom: {
          another_field: 'test',
          valid_field: true,
        },
      },
    )

    expect(result[:issues]).to be_empty
    expect(result[:params][:custom][:valid_field]).to be(true)
    expect(result[:params][:custom][:another_field]).to eq('test')
  end
end
