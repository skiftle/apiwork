# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Custom type hierarchical scoping and serialization', type: :integration do
  before(:all) do
    Object.send(:remove_const, :TestScopedContract) if defined?(TestScopedContract)
    Object.send(:remove_const, :TestScopedSchema) if defined?(TestScopedSchema)

    class TestScopedSchema < Apiwork::Schema::Base
      model Post
      root :test_scoped

      attribute :id
      attribute :title
    end

    class TestScopedContract < Apiwork::Contract::Base
      schema TestScopedSchema

      type :contract_level_type do
        param :field1, type: :string, required: false
      end

      action :custom_action do
        type :action_level_type do
          param :field2, type: :string, required: false
        end

        input do
          type :input_level_type do
            param :field3, type: :string, required: false
          end

          param :contract_param, type: :contract_level_type, required: false
          param :action_param, type: :action_level_type, required: false
          param :input_param, type: :input_level_type, required: false
        end
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestScopedContract) if defined?(TestScopedContract)
    Object.send(:remove_const, :TestScopedSchema) if defined?(TestScopedSchema)
  end

  describe 'Type serialization with hierarchical scoping' do
    it 'serializes types without NoMethodError' do
      expect do
        Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')
      end.not_to raise_error
    end

    it 'includes contract-level types with correct qualified name' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')

      # Contract-level type should be qualified as: test_scoped_contract_level_type
      expect(all_types).to have_key(:test_scoped_contract_level_type)
      expect(all_types[:test_scoped_contract_level_type]).to have_key(:field1)
    end

    it 'includes action-level types with correct qualified name' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')

      # Action-level type should be qualified as: test_scoped_custom_action_action_level_type
      expect(all_types).to have_key(:test_scoped_custom_action_action_level_type)
      expect(all_types[:test_scoped_custom_action_action_level_type]).to have_key(:field2)
    end

    it 'includes input-level types with correct qualified name' do
      all_types = Apiwork::Contract::Descriptors::Registry.serialize_all_types_for_api('api/v1')

      # Input-level type should be qualified as: test_scoped_custom_action_input_input_level_type
      # But it's actually showing as: test_scoped_input_input_level_type
      # This suggests the Definition doesn't have action_name set when the type is registered
      expect(all_types).to have_key(:test_scoped_custom_action_input_input_level_type)
      expect(all_types[:test_scoped_custom_action_input_input_level_type]).to have_key(:field3)
    end

    it 'serializes action definition without errors' do
      action_def = TestScopedContract.action_definition(:custom_action)

      expect do
        action_def.as_json
      end.not_to raise_error
    end

    it 'references types correctly in action input' do
      action_def = TestScopedContract.action_definition(:custom_action)
      serialized = action_def.as_json

      # Input should reference the qualified type names
      input = serialized[:input]
      expect(input[:contract_param][:type]).to eq(:test_scoped_contract_level_type)
      expect(input[:action_param][:type]).to eq(:test_scoped_custom_action_action_level_type)
      expect(input[:input_param][:type]).to eq(:test_scoped_custom_action_input_input_level_type)
    end
  end
end
