# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract custom type unknown field validation' do
  let(:contract_class) do
    Class.new(Apiwork::Contract::Base) do
      class << self
        def resource_class
          nil # No resource for this test
        end
      end

      # Define a custom type with specific fields
      type :my_custom_type do
        param :valid_field, type: :boolean, required: false
        param :another_field, type: :string, required: false
      end

      action :index do
        input do
          param :custom, type: :my_custom_type, required: false
        end
      end
    end
  end

  let(:contract) { contract_class.new }
  let(:action_def) { contract_class.action_definition(:index) }

  it 'catches unknown fields in custom types' do
    result = action_def.input_definition.validate({
      custom: {
        invalid_field: true  # This should be caught as unknown
      }
    })

    expect(result[:errors]).not_to be_empty
    error = result[:errors].first
    expect(error.code).to eq(:field_unknown)
    expect(error.field).to eq(:invalid_field)
  end

  it 'allows known fields in custom types' do
    result = action_def.input_definition.validate({
      custom: {
        valid_field: true,
        another_field: 'test'
      }
    })

    expect(result[:errors]).to be_empty
    expect(result[:params][:custom][:valid_field]).to eq(true)
    expect(result[:params][:custom][:another_field]).to eq('test')
  end
end
