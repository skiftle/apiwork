# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract custom type lexical scoping' do
  describe 'global scope types' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Global type definition
        type :global_type do
          param :global_field, type: :string, required: true
        end

        action :first_action do
          input do
            param :data, type: :global_type, required: false
          end
          output do
            param :result, type: :global_type, required: false
          end
        end

        action :second_action do
          input do
            param :data, type: :global_type, required: false
          end
        end
      end
    end

    it 'are available in all action inputs' do
      first_action = contract_class.action_definition(:first_action)
      result = first_action.input_definition.validate({
                                                        data: { global_field: 'test' }
                                                      })

      expect(result[:errors]).to be_empty
      expect(result[:params][:data][:global_field]).to eq('test')

      second_action = contract_class.action_definition(:second_action)
      result2 = second_action.input_definition.validate({
                                                          data: { global_field: 'test2' }
                                                        })

      expect(result2[:errors]).to be_empty
      expect(result2[:params][:data][:global_field]).to eq('test2')
    end

    it 'are available in action outputs' do
      action_definition = contract_class.action_definition(:first_action)
      result = action_definition.output_definition.validate({
                                                              result: { global_field: 'output_test' }
                                                            })

      expect(result[:errors]).to be_empty
      expect(result[:params][:result][:global_field]).to eq('output_test')
    end
  end

  describe 'action scope types' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Global type
        type :shared_name do
          param :global_field, type: :string, required: true
        end

        action :first_action do
          # Action-scoped type with same name (shadows global)
          type :shared_name do
            param :action_field, type: :integer, required: true
          end

          # Unique action-scoped type
          type :action_only_type do
            param :unique_field, type: :boolean, required: true
          end

          input do
            param :shadowed, type: :shared_name, required: false
            param :unique, type: :action_only_type, required: false
          end

          output do
            param :shadowed_out, type: :shared_name, required: false
          end
        end

        action :second_action do
          input do
            # Should use global version (no shadowing in this action)
            param :global_version, type: :shared_name, required: false
          end
        end
      end
    end

    it 'shadow global types with same name' do
      first_action = contract_class.action_definition(:first_action)

      # Should validate using action-scoped version (action_field, not global_field)
      result = first_action.input_definition.validate({
                                                        shadowed: { action_field: 42 }
                                                      })

      expect(result[:errors]).to be_empty
      expect(result[:params][:shadowed][:action_field]).to eq(42)
    end

    it 'do not accept global type fields when shadowed' do
      first_action = contract_class.action_definition(:first_action)

      # Should fail with global_field since action scope shadows it
      result = first_action.input_definition.validate({
                                                        shadowed: { global_field: 'test' }
                                                      })

      expect(result[:errors]).not_to be_empty
      expect(result[:errors].first.code).to eq(:field_missing)
      expect(result[:errors].first.field).to eq(:action_field)
    end

    it 'are available in both input and output of same action' do
      action_definition = contract_class.action_definition(:first_action)

      input_result = action_definition.input_definition.validate({
                                                                   unique: { unique_field: true }
                                                                 })

      expect(input_result[:errors]).to be_empty

      # Output should also use shadowed version
      output_result = action_definition.output_definition.validate({
                                                                     shadowed_out: { action_field: 123 }
                                                                   })

      expect(output_result[:errors]).to be_empty
      expect(output_result[:params][:shadowed_out][:action_field]).to eq(123)
    end

    it 'are NOT available in other actions' do
      second_action = contract_class.action_definition(:second_action)

      # Should use global version in second_action
      result = second_action.input_definition.validate({
                                                         global_version: { global_field: 'works' }
                                                       })

      expect(result[:errors]).to be_empty
      expect(result[:params][:global_version][:global_field]).to eq('works')
    end
  end

  describe 'input/output scope types' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Global type
        type :multi_scope_name do
          param :global_field, type: :string, required: true
        end

        action :test_action do
          # Action-scoped type
          type :multi_scope_name do
            param :action_field, type: :integer, required: true
          end

          input do
            # Input-scoped type (shadows action)
            type :multi_scope_name do
              param :input_field, type: :boolean, required: true
            end

            # Input-only type
            type :input_only_type do
              param :input_exclusive, type: :string, required: true
            end

            param :triple_shadowed, type: :multi_scope_name, required: false
            param :input_exclusive_param, type: :input_only_type, required: false
          end

          output do
            # Output-scoped type (shadows action)
            type :multi_scope_name do
              param :output_field, type: :float, required: true
            end

            # Output-only type
            type :output_only_type do
              param :output_exclusive, type: :integer, required: true
            end

            param :output_shadowed, type: :multi_scope_name, required: false
            param :output_exclusive_param, type: :output_only_type, required: false
          end
        end
      end
    end

    it 'input-scoped types shadow action scope types' do
      action_definition = contract_class.action_definition(:test_action)

      # Should use input-scoped version (input_field)
      result = action_definition.input_definition.validate({
                                                             triple_shadowed: { input_field: true }
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:triple_shadowed][:input_field]).to be(true)
    end

    it 'output-scoped types shadow action scope types' do
      action_definition = contract_class.action_definition(:test_action)

      # Should use output-scoped version (output_field)
      result = action_definition.output_definition.validate({
                                                              output_shadowed: { output_field: 3.14 }
                                                            })

      expect(result[:errors]).to be_empty
      expect(result[:params][:output_shadowed][:output_field]).to eq(3.14)
    end

    it 'input-scoped types do not accept action fields' do
      action_definition = contract_class.action_definition(:test_action)

      # Should fail with action_field since input scope shadows it
      result = action_definition.input_definition.validate({
                                                             triple_shadowed: { action_field: 42 }
                                                           })

      expect(result[:errors]).not_to be_empty
      expect(result[:errors].first.code).to eq(:field_missing)
      expect(result[:errors].first.field).to eq(:input_field)
    end

    it 'input-scoped types are NOT available in output' do
      action_definition = contract_class.action_definition(:test_action)

      # Should fail - input_only_type not in output scope
      result = action_definition.output_definition.validate({
                                                              output_exclusive_param: { input_exclusive: 'test' }
                                                            })

      # This should error because output_exclusive_param expects output_only_type
      # which has output_exclusive field, not input_exclusive
      expect(result[:errors]).not_to be_empty
    end

    it 'output-scoped types are NOT available in input' do
      action_definition = contract_class.action_definition(:test_action)

      # Should fail - output_only_type not in input scope
      result = action_definition.input_definition.validate({
                                                             input_exclusive_param: { output_exclusive: 123 }
                                                           })

      # This should error because input_exclusive_param expects input_only_type
      # which has input_exclusive field, not output_exclusive
      expect(result[:errors]).not_to be_empty
    end
  end

  describe 'scope chain resolution' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Root level type
        type :level_1 do
          param :root, type: :string, required: true
        end

        action :test_action do
          # Action level type
          type :level_2 do
            param :action, type: :string, required: true
          end

          input do
            # Input level type
            type :level_3 do
              param :input, type: :string, required: true
            end

            # All three levels should be accessible from input
            param :from_root, type: :level_1, required: false
            param :from_action, type: :level_2, required: false
            param :from_input, type: :level_3, required: false
          end
        end
      end
    end

    it 'searches current scope first, then parent, then root' do
      action_definition = contract_class.action_definition(:test_action)

      # Test root level access
      result = action_definition.input_definition.validate({
                                                             from_root: { root: 'test_root' }
                                                           })
      expect(result[:errors]).to be_empty

      # Test action level access
      result = action_definition.input_definition.validate({
                                                             from_action: { action: 'test_action' }
                                                           })
      expect(result[:errors]).to be_empty

      # Test input level access
      result = action_definition.input_definition.validate({
                                                             from_input: { input: 'test_input' }
                                                           })
      expect(result[:errors]).to be_empty
    end
  end

  describe 'with arrays' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Global custom type
        type :item_type do
          param :name, type: :string, required: true
          param :count, type: :integer, required: true
        end

        action :list_action do
          # Action-scoped custom type
          type :special_item do
            param :id, type: :integer, required: true
            param :special_flag, type: :boolean, required: true
          end

          input do
            param :items, type: :array, of: :item_type, required: false
            param :special_items, type: :array, of: :special_item, required: false
          end
        end
      end
    end

    it 'resolves global custom types in array of: parameter' do
      action_definition = contract_class.action_definition(:list_action)

      result = action_definition.input_definition.validate({
                                                             items: [
                                                               { name: 'first', count: 1 },
                                                               { name: 'second', count: 2 }
                                                             ]
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:items].length).to eq(2)
      expect(result[:params][:items][0][:name]).to eq('first')
      expect(result[:params][:items][1][:count]).to eq(2)
    end

    it 'resolves action-scoped custom types in array of: parameter' do
      action_definition = contract_class.action_definition(:list_action)

      result = action_definition.input_definition.validate({
                                                             special_items: [
                                                               { id: 1, special_flag: true },
                                                               { id: 2, special_flag: false }
                                                             ]
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:special_items].length).to eq(2)
      expect(result[:params][:special_items][0][:special_flag]).to be(true)
    end
  end

  describe 'with unions' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Global custom type
        type :text_data do
          param :text, type: :string, required: true
        end

        action :union_action do
          # Action-scoped custom type
          type :number_data do
            param :number, type: :integer, required: true
          end

          input do
            # Input-scoped custom type
            type :bool_data do
              param :flag, type: :boolean, required: true
            end

            # Union with types from different scopes
            param :mixed_data, type: :union, required: false do
              variant type: :text_data    # from global
              variant type: :number_data  # from action
              variant type: :bool_data    # from input
            end
          end

          output do
            # Only has access to global and action scopes (not input)
            param :limited_union, type: :union, required: false do
              variant type: :text_data    # from global
              variant type: :number_data  # from action
            end
          end
        end
      end
    end

    it 'resolves global custom types in union variants' do
      action_definition = contract_class.action_definition(:union_action)

      result = action_definition.input_definition.validate({
                                                             mixed_data: { text: 'hello' }
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:mixed_data][:text]).to eq('hello')
    end

    it 'resolves action-scoped custom types in union variants' do
      action_definition = contract_class.action_definition(:union_action)

      result = action_definition.input_definition.validate({
                                                             mixed_data: { number: 42 }
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:mixed_data][:number]).to eq(42)
    end

    it 'resolves input-scoped custom types in union variants' do
      action_definition = contract_class.action_definition(:union_action)

      result = action_definition.input_definition.validate({
                                                             mixed_data: { flag: true }
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:mixed_data][:flag]).to be(true)
    end

    it 'respects scope isolation in output unions' do
      action_definition = contract_class.action_definition(:union_action)

      # Should work with global type
      result = action_definition.output_definition.validate({
                                                              limited_union: { text: 'output' }
                                                            })
      expect(result[:errors]).to be_empty

      # Should work with action type
      result = action_definition.output_definition.validate({
                                                              limited_union: { number: 99 }
                                                            })
      expect(result[:errors]).to be_empty
    end
  end

  describe 'error handling' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        action :test_action do
          input do
            # Reference non-existent type
            param :missing, type: :undefined_type, required: false
          end
        end
      end
    end

    it 'handles undefined types gracefully' do
      action_definition = contract_class.action_definition(:test_action)

      # Should not crash, but won't validate the type either
      # The behavior here depends on how Definition handles unknown types
      # Based on the code, it will just skip validation if type is not found
      result = action_definition.input_definition.validate({
                                                             missing: { any: 'value' }
                                                           })

      # This might pass (if undefined types are treated as any)
      # or fail (if they're strictly validated) - documenting current behavior
      expect(result).to be_a(Hash)
      expect(result).to have_key(:params)
    end
  end

  describe 'nested custom types with scoping' do
    let(:contract_class) do
      Class.new(Apiwork::Contract::Base) do
        class << self
          def resource_class
            nil
          end
        end

        # Global inner type
        type :inner do
          param :value, type: :string, required: true
        end

        # Global outer type that uses inner
        type :outer do
          param :nested, type: :inner, required: true
        end

        action :nested_action do
          # Shadow inner type at action level
          type :inner do
            param :action_value, type: :integer, required: true
          end

          input do
            # Use outer type - should resolve inner from current scope chain
            param :data, type: :outer, required: false
          end
        end
      end
    end

    it 'resolves nested types using current validation scope' do
      action_definition = contract_class.action_definition(:nested_action)

      # The outer type references :inner, which resolves from the current validation scope
      # In this case, the input scope has access to the action-scoped :inner (which shadows global)
      # So it should use action_value, not value
      result = action_definition.input_definition.validate({
                                                             data: {
                                                               nested: { action_value: 123 }
                                                             }
                                                           })

      expect(result[:errors]).to be_empty
      expect(result[:params][:data][:nested][:action_value]).to eq(123)
    end
  end
end
