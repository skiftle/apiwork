# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Imports' do
  after(:each) do
    # Only clear local types/enums, not global ones (like :sort_direction)
    Apiwork::Contract::Descriptors::TypeStore.clear_local!
    Apiwork::Contract::Descriptors::EnumStore.clear_local!
  end

  describe 'basic import functionality' do
    let(:user_contract) do
      Class.new(Apiwork::Contract::Base) do
        def self.name
          'UserContract'
        end

        type :address do
          param :street, type: :string, required: true
          param :city, type: :string, required: true
          param :country, type: :string, required: true
        end

        enum :status, %w[active inactive suspended]
      end
    end

    let(:order_contract) do
      Class.new(Apiwork::Contract::Base) do
        def self.name
          'OrderContract'
        end

        type :order_item do
          param :product_id, type: :uuid, required: true
          param :quantity, type: :integer, required: true
        end
      end
    end

    it 'allows importing types from another contract' do
      uc = user_contract
      importing_contract = Class.new(Apiwork::Contract::Base) do
        import uc, as: :user

        action :create do
          input do
            param :shipping_address, type: :user_address, required: true
          end
        end
      end

      # Should be able to resolve the imported type
      resolved = importing_contract.resolve_custom_type(:user_address)
      expect(resolved).not_to be_nil
    end

    it 'allows importing enums from another contract' do
      uc = user_contract
      importing_contract = Class.new(Apiwork::Contract::Base) do
        import uc, as: :user

        action :create do
          input do
            param :account_status, type: :string, enum: :user_status
          end
        end
      end

      # Should be able to resolve the imported enum
      enum_values = Apiwork::Contract::Descriptors::EnumStore.resolve(
        :user_status,
        contract_class: importing_contract
      )
      expect(enum_values).to eq(%w[active inactive suspended])
    end

    it 'supports multiple imports' do
      uc = user_contract
      oc = order_contract
      importing_contract = Class.new(Apiwork::Contract::Base) do
        import uc, as: :user
        import oc, as: :order

        action :create do
          input do
            param :shipping_address, type: :user_address
            param :items, type: :array, of: :order_order_item
          end
        end
      end

      user_type = importing_contract.resolve_custom_type(:user_address)
      expect(user_type).not_to be_nil

      order_type = importing_contract.resolve_custom_type(:order_order_item)
      expect(order_type).not_to be_nil
    end

    it 'validates that import is a Class' do
      expect do
        Class.new(Apiwork::Contract::Base) do
          import 'UserContract', as: :user
        end
      end.to raise_error(ArgumentError, /import must be a Class constant/)
    end

    it 'validates that import is a Contract class' do
      not_a_contract = Class.new

      expect do
        Class.new(Apiwork::Contract::Base) do
          import not_a_contract, as: :other
        end
      end.to raise_error(ArgumentError, /import must be a Contract class/)
    end

    it 'validates that alias is a Symbol' do
      uc = user_contract
      expect do
        Class.new(Apiwork::Contract::Base) do
          import uc, as: 'user'
        end
      end.to raise_error(ArgumentError, /import alias must be a Symbol/)
    end
  end

  describe 'with anonymous schema-based contracts' do
    it 'allows importing from anonymous contracts' do
      # Create an anonymous contract
      user_contract = Class.new(Apiwork::Contract::Base)

      # Register a type on it
      user_contract.class_eval do
        type :address do
          param :street, type: :string
        end
      end

      # Import from the anonymous contract
      uc = user_contract
      order_contract = Class.new(Apiwork::Contract::Base) do
        import uc, as: :user

        action :create do
          input do
            param :shipping_address, type: :user_address
          end
        end
      end

      # Should be able to resolve
      resolved = order_contract.resolve_custom_type(:user_address)
      expect(resolved).not_to be_nil
    end
  end

  describe 'circular import detection' do
    it 'allows mutual imports between contracts' do
      contract_a = Class.new(Apiwork::Contract::Base) do
        def self.name
          'ContractA'
        end
      end

      contract_b = Class.new(Apiwork::Contract::Base) do
        def self.name
          'ContractB'
        end
      end

      # Create mutual imports (both contracts import each other)
      a = contract_a
      b = contract_b

      contract_a.class_eval do
        import b, as: :b

        type :a_type do
          param :value, type: :string
        end
      end

      contract_b.class_eval do
        import a, as: :a

        type :b_type do
          param :value, type: :integer
        end
      end

      # Mutual imports should work fine - no circular error
      expect(contract_a.resolve_custom_type(:b_b_type)).not_to be_nil
      expect(contract_b.resolve_custom_type(:a_a_type)).not_to be_nil
    end

    it 'detects circular import loops during resolution' do
      # This test verifies the visited_contracts Set prevents infinite loops
      # The circular check triggers when we visit the same contract twice in one resolution chain

      contract_a = Class.new(Apiwork::Contract::Base) do
        def self.name
          'ContractA'
        end
      end

      contract_b = Class.new(Apiwork::Contract::Base) do
        def self.name
          'ContractB'
        end
      end

      contract_c = Class.new(Apiwork::Contract::Base) do
        def self.name
          'ContractC'
        end
      end

      a = contract_a
      b = contract_b
      c = contract_c

      # Create a chain: A imports B, B imports C, C imports A
      contract_a.class_eval do
        import b, as: :b
      end

      contract_b.class_eval do
        import c, as: :c
      end

      contract_c.class_eval do
        import a, as: :a
      end

      # Now try to resolve a type that would loop: A -> B -> C -> A
      # Looking for :b_c_a_something from contract_a should detect the loop
      expect do
        contract_a.resolve_custom_type(:b_c_a_something)
      end.to raise_error(Apiwork::CircularImportError)
    end
  end

  describe 'serialization with imports' do
    let(:user_contract) do
      Class.new(Apiwork::Contract::Base) do
        def self.name
          'UserContract'
        end

        type :address do
          param :street, type: :string, required: true
          param :city, type: :string, required: true
        end
      end
    end

    it 'serializes imported types correctly' do
      uc = user_contract
      order_contract = Class.new(Apiwork::Contract::Base) do
        import uc, as: :user

        action :create do
          input do
            param :shipping_address, type: :user_address, required: true
          end
        end
      end

      action_def = order_contract.action_definition(:create)
      serialized = action_def.as_json

      # The input should reference the imported type
      expect(serialized[:input][:shipping_address][:type]).to eq(:user_address)
      expect(serialized[:input][:shipping_address][:required]).to be true
    end
  end

  describe 'type resolution priority' do
    let(:base_contract) do
      Class.new(Apiwork::Contract::Base) do
        def self.name
          'BaseContract'
        end

        type :metadata do
          param :version, type: :integer
        end
      end
    end

    it 'prefers local types over imported types with same name' do
      bc = base_contract
      importing_contract = Class.new(Apiwork::Contract::Base) do
        import bc, as: :base

        # Define local type with same base name
        type :metadata do
          param :version, type: :string  # Different type
        end

        action :create do
          input do
            param :local_meta, type: :metadata  # Should use local
            param :imported_meta, type: :base_metadata  # Should use imported
          end
        end
      end

      # Local type should be resolved for :metadata
      local_type = importing_contract.resolve_custom_type(:metadata)
      expect(local_type).not_to be_nil

      # Imported type should be resolved for :base_metadata
      imported_type = importing_contract.resolve_custom_type(:base_metadata)
      expect(imported_type).not_to be_nil
    end
  end
end
