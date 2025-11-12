# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Enum resolution in custom types - basic functionality', type: :integration do
  before(:all) do
    Object.send(:remove_const, :TestEnumResolutionContract) if defined?(TestEnumResolutionContract)

    class TestEnumResolutionContract < Apiwork::Contract::Base
      action :archive do
        enum :hahahehe, %w[asc desc]

        type :hehe do
          param :equal, type: :string, required: false, enum: :hahahehe
          param :contains, type: :string, required: false
          param :starts_with, type: :string, required: false
        end

        input do
          param :filter, type: :hehe, required: false
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestEnumResolutionContract) if defined?(TestEnumResolutionContract)
  end

  it 'does not raise ArgumentError when defining enum in action and using it in action-level custom type' do
    expect do
      action_def = TestEnumResolutionContract.action_definition(:archive)
      input_def = action_def.merged_input_definition
      input_def.params
    end.not_to raise_error
  end

  it 'can serialize the action definition without errors' do
    expect do
      action_def = TestEnumResolutionContract.action_definition(:archive)
      action_def.as_json
    end.not_to raise_error
  end

  it 'includes the enum in the registered enums list' do
    all_enums = Apiwork::Contract::Descriptors::Registry.serialize_all_enums_for_api('api/v1')
    expect(all_enums).to have_key(:test_enum_resolution_archive_hahahehe)
    expect(all_enums[:test_enum_resolution_archive_hahahehe]).to eq(%w[asc desc])
  end
end
