# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract inheritance', type: :integration do
  def create_child_contract(parent, &block)
    child = Class.new(parent)
    child.instance_variable_set(:@api_class, ApiTestHelper.api_class)
    child.class_eval(&block) if block_given?
    child
  end

  describe 'Object inheritance' do
    let(:parent_contract) do
      create_test_contract do
        object :address do
          string :street
          string :city
        end
      end
    end

    it 'inherits object types from parent contract' do
      child = create_child_contract(parent_contract)

      resolved = child.resolve_custom_type(:address)
      expect(resolved).not_to be_nil
    end

    it 'allows child to define additional types' do
      child = create_child_contract(parent_contract) do
        object :payment do
          decimal :amount
        end
      end

      expect(child.resolve_custom_type(:address)).not_to be_nil
      expect(child.resolve_custom_type(:payment)).not_to be_nil
    end

    it 'allows child to override parent types' do
      child = create_child_contract(parent_contract) do
        object :address do
          string :full_address
        end
      end

      resolved = child.resolve_custom_type(:address)
      expect(resolved).not_to be_nil
    end
  end

  describe 'Enum inheritance' do
    let(:parent_contract) do
      create_test_contract do
        enum :status, values: %w[active inactive]
      end
    end

    it 'inherits enums from parent contract' do
      child = create_child_contract(parent_contract)

      values = child.enum_values(:status)
      expect(values).to eq(%w[active inactive])
    end

    it 'allows child to define additional enums' do
      child = create_child_contract(parent_contract) do
        enum :priority, values: %w[low high]
      end

      expect(child.enum_values(:status)).to eq(%w[active inactive])
      expect(child.enum_values(:priority)).to eq(%w[low high])
    end
  end

  describe 'Union inheritance' do
    let(:parent_contract) do
      create_test_contract do
        union :payment_method, discriminator: :type do
          variant tag: 'card' do
            object do
              string :last_four
            end
          end
        end
      end
    end

    it 'inherits unions from parent contract' do
      child = create_child_contract(parent_contract)

      resolved = child.resolve_custom_type(:payment_method)
      expect(resolved).not_to be_nil
      expect(resolved.union?).to be(true)
    end
  end

  describe 'Multi-level inheritance' do
    let(:grandparent_contract) do
      create_test_contract do
        object :base_type do
          string :id
        end
      end
    end

    let(:parent_contract) do
      create_child_contract(grandparent_contract) do
        object :parent_type do
          string :name
        end
      end
    end

    it 'inherits types through multiple levels' do
      child = create_child_contract(parent_contract) do
        object :child_type do
          string :value
        end
      end

      expect(child.resolve_custom_type(:base_type)).not_to be_nil
      expect(child.resolve_custom_type(:parent_type)).not_to be_nil
      expect(child.resolve_custom_type(:child_type)).not_to be_nil
    end
  end

  describe 'Inheritance with imports' do
    let(:external_contract) do
      create_test_contract do
        object :external_type do
          string :value
        end
      end
    end

    let(:parent_contract) do
      imported_contract = external_contract

      create_test_contract do
        import imported_contract, as: :ext

        object :parent_type do
          string :name
        end
      end
    end

    it 'child inherits both parent types and parent imports' do
      child = create_child_contract(parent_contract)

      expect(child.resolve_custom_type(:parent_type)).not_to be_nil
      expect(child.resolve_custom_type(:ext_external_type)).not_to be_nil
    end

    it 'child can define its own imports alongside inherited ones' do
      other_contract = create_test_contract do
        object :other_type do
          string :value
        end
      end

      child = create_child_contract(parent_contract) do
        import other_contract, as: :other
      end

      expect(child.resolve_custom_type(:parent_type)).not_to be_nil
      expect(child.resolve_custom_type(:ext_external_type)).not_to be_nil
      expect(child.resolve_custom_type(:other_other_type)).not_to be_nil
    end
  end
end
