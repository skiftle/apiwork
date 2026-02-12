# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract Imports' do
  describe 'basic import functionality' do
    let(:user_contract) do
      create_test_contract do
        object :address do
          string :street
          string :city
          string :country_code
        end

        enum :status, values: %w[active inactive suspended]
      end
    end

    let(:order_contract) do
      create_test_contract do
        object :order_item do
          uuid :product_id
          integer :quantity
        end
      end
    end

    it 'allows importing types from another contract' do
      uc = user_contract
      importing_contract = create_test_contract do
        import uc, as: :user

        action :create do
          request do
            body do
              reference :shipping_address, to: :user_address
            end
          end
        end
      end

      # Should be able to resolve the imported type
      resolved = importing_contract.resolve_custom_type(:user_address)
      expect(resolved).not_to be_nil
    end

    it 'allows importing enums from another contract' do
      uc = user_contract
      importing_contract = create_test_contract do
        import uc, as: :user

        action :create do
          request do
            body do
              string :account_status, enum: :user_status
            end
          end
        end
      end

      enum_values = importing_contract.enum_values(:user_status)
      expect(enum_values).to eq(%w[active inactive suspended])
    end

    it 'supports multiple imports' do
      uc = user_contract
      oc = order_contract
      importing_contract = create_test_contract do
        import uc, as: :user
        import oc, as: :order

        action :create do
          request do
            body do
              reference :shipping_address, to: :user_address
              array :items do
                reference :order_order_item
              end
            end
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
        create_test_contract do
          import 'UserContract', as: :user
        end
      end.to raise_error(Apiwork::ConfigurationError, /import must be a Class constant/)
    end

    it 'validates that import is a Contract class' do
      not_a_contract = Class.new

      expect do
        create_test_contract do
          import not_a_contract, as: :other
        end
      end.to raise_error(Apiwork::ConfigurationError, /import must be a Contract class/)
    end

    it 'validates that alias is a Symbol' do
      uc = user_contract
      expect do
        create_test_contract do
          import uc, as: 'user'
        end
      end.to raise_error(Apiwork::ConfigurationError, /import alias must be a Symbol/)
    end
  end

  describe 'with dynamically created contracts' do
    it 'allows importing from dynamically created contracts' do
      user_contract = create_test_contract do
        object :address do
          string :street
        end
      end

      uc = user_contract
      order_contract = create_test_contract do
        import uc, as: :user

        action :create do
          request do
            body do
              reference :shipping_address, to: :user_address
            end
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
      contract_a = create_test_contract
      contract_b = create_test_contract

      a = contract_a
      b = contract_b

      contract_a.class_eval do
        import b, as: :b

        object :a_type do
          string :value
        end
      end

      contract_b.class_eval do
        import a, as: :a

        object :b_type do
          integer :value
        end
      end

      expect(contract_a.resolve_custom_type(:b_b_type)).not_to be_nil
      expect(contract_b.resolve_custom_type(:a_a_type)).not_to be_nil
    end

    it 'detects circular import loops during resolution' do
      contract_a = create_test_contract
      contract_b = create_test_contract
      contract_c = create_test_contract

      a = contract_a
      b = contract_b
      c = contract_c

      contract_a.class_eval do
        import b, as: :b
      end

      contract_b.class_eval do
        import c, as: :c
      end

      contract_c.class_eval do
        import a, as: :a
      end

      expect do
        contract_a.resolve_custom_type(:b_c_a_something)
      end.to raise_error(Apiwork::ConfigurationError)
    end
  end

  describe 'serialization with imports' do
    let(:user_contract) do
      create_test_contract do
        object :address do
          string :street
          string :city
        end
      end
    end

    it 'serializes imported types correctly' do
      uc = user_contract
      order_contract = create_test_contract do
        import uc, as: :user

        action :create do
          request do
            body do
              reference :shipping_address, to: :user_address
            end
          end
        end
      end

      action = order_contract.action_for(:create)
      serialized = Apiwork::Introspection::Dump::Action.new(action).to_h

      # The request body should reference the imported type
      expect(serialized[:request][:body][:shipping_address][:type]).to eq(:reference)
      expect(serialized[:request][:body][:shipping_address][:reference]).to eq(:user_address)
      # Required is now the default, so optional should be false
      expect(serialized[:request][:body][:shipping_address][:optional]).to be(false)
    end
  end

  describe 'type resolution priority' do
    let(:base_contract) do
      create_test_contract do
        object :metadata do
          integer :version
        end
      end
    end

    it 'prefers local types over imported types with same name' do
      bc = base_contract
      importing_contract = create_test_contract do
        import bc, as: :base

        # Define local type with same base name
        object :metadata do
          string :version # Different type
        end

        action :create do
          request do
            body do
              reference :local_meta, to: :metadata
              reference :imported_meta, to: :base_metadata
            end
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
