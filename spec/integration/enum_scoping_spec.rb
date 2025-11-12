# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Enum hierarchical scoping and serialization', type: :integration do
  # Test enums at contract, action, and input/output levels
  # Verifies that enums defined at different scopes are correctly serialized
  # and that qualified names follow the hierarchical naming pattern

  before(:all) do
    # Create a test contract with enums at different scopes
    Object.send(:remove_const, :TestEnumScopedContract) if defined?(TestEnumScopedContract)
    Object.send(:remove_const, :TestEnumScopedSchema) if defined?(TestEnumScopedSchema)

    class TestEnumScopedSchema < Apiwork::Schema::Base
      model Post
      root :test_enum_scoped

      attribute :id
      attribute :title
    end

    class TestEnumScopedContract < Apiwork::Contract::Base
      schema TestEnumScopedSchema

      # Contract-level enum
      enum :contract_status, %w[draft published archived]

      action :custom_action do
        # Action-level enum
        enum :action_priority, %w[low medium high]

        input do
          # Input-level enum
          enum :input_visibility, %w[public private]

          param :status, type: :string, enum: :contract_status
          param :priority, type: :string, enum: :action_priority
          param :visibility, type: :string, enum: :input_visibility
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestEnumScopedContract) if defined?(TestEnumScopedContract)
    Object.send(:remove_const, :TestEnumScopedSchema) if defined?(TestEnumScopedSchema)
  end

  describe 'Enum serialization with hierarchical scoping' do
    it 'serializes enums without errors' do
      expect do
        Apiwork::Contract::Descriptors::Registry.serialize_all_enums_for_api('api/v1')
      end.not_to raise_error
    end

    it 'includes contract-level enums with correct qualified name' do
      all_enums = Apiwork::Contract::Descriptors::Registry.serialize_all_enums_for_api('api/v1')

      # Contract-level enum should be qualified as: test_enum_scoped_contract_status
      expect(all_enums).to have_key(:test_enum_scoped_contract_status)
      expect(all_enums[:test_enum_scoped_contract_status]).to eq(%w[draft published archived])
    end

    it 'includes action-level enums with correct qualified name' do
      all_enums = Apiwork::Contract::Descriptors::Registry.serialize_all_enums_for_api('api/v1')

      # Action-level enum should be qualified as: test_enum_scoped_custom_action_action_priority
      expect(all_enums).to have_key(:test_enum_scoped_custom_action_action_priority)
      expect(all_enums[:test_enum_scoped_custom_action_action_priority]).to eq(%w[low medium high])
    end

    it 'includes input-level enums with correct qualified name' do
      all_enums = Apiwork::Contract::Descriptors::Registry.serialize_all_enums_for_api('api/v1')

      # Input-level enum should be qualified as: test_enum_scoped_custom_action_input_input_visibility
      expect(all_enums).to have_key(:test_enum_scoped_custom_action_input_input_visibility)
      expect(all_enums[:test_enum_scoped_custom_action_input_input_visibility]).to eq(%w[public private])
    end

    it 'serializes action definition without errors' do
      action_def = TestEnumScopedContract.action_definition(:custom_action)

      expect do
        action_def.as_json
      end.not_to raise_error
    end

    it 'references enums correctly in action input' do
      action_def = TestEnumScopedContract.action_definition(:custom_action)
      serialized = action_def.as_json

      # Input should reference the qualified enum names
      input = serialized[:input]
      expect(input[:status][:enum]).to eq(:test_enum_scoped_contract_status)
      expect(input[:priority][:enum]).to eq(:test_enum_scoped_custom_action_action_priority)
      expect(input[:visibility][:enum]).to eq(:test_enum_scoped_custom_action_input_input_visibility)
    end

    it 'resolves enum values during validation' do
      action_def = TestEnumScopedContract.action_definition(:custom_action)
      merged_input = action_def.merged_input_definition

      # Contract-level enum
      valid_data_1 = { status: 'published', priority: 'low', visibility: 'public' }
      result_1 = merged_input.validate(valid_data_1)
      expect(result_1[:errors]).to be_empty

      # Invalid contract-level enum value
      invalid_data_1 = { status: 'invalid', priority: 'low', visibility: 'public' }
      result_2 = merged_input.validate(invalid_data_1)
      expect(result_2[:errors]).not_to be_empty
      expect(result_2[:errors].first.field).to eq(:status)

      # Invalid action-level enum value
      invalid_data_2 = { status: 'draft', priority: 'invalid', visibility: 'public' }
      result_3 = merged_input.validate(invalid_data_2)
      expect(result_3[:errors]).not_to be_empty
      expect(result_3[:errors].first.field).to eq(:priority)

      # Invalid input-level enum value
      invalid_data_3 = { status: 'draft', priority: 'low', visibility: 'invalid' }
      result_4 = merged_input.validate(invalid_data_3)
      expect(result_4[:errors]).not_to be_empty
      expect(result_4[:errors].first.field).to eq(:visibility)
    end
  end
end
