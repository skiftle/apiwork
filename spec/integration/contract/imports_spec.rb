# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract imports', type: :integration do
  describe 'Basic import' do
    let(:invoice_contract) do
      create_test_contract do
        object :address do
          string :street
          string :city
        end

        enum :status, values: %w[draft sent paid]
      end
    end

    it 'imports object types from another contract' do
      ic = invoice_contract

      importing_contract = create_test_contract do
        import ic, as: :invoice

        action :create do
          request do
            body do
              reference :billing_address, to: :invoice_address
            end
          end
        end
      end

      resolved = importing_contract.resolve_custom_type(:invoice_address)
      expect(resolved).not_to be_nil
    end

    it 'imports enum types from another contract' do
      ic = invoice_contract

      importing_contract = create_test_contract do
        import ic, as: :invoice

        action :create do
          request do
            body do
              string :payment_status, enum: :invoice_status
            end
          end
        end
      end

      enum_values = importing_contract.enum_values(:invoice_status)
      expect(enum_values).to eq(%w[draft sent paid])
    end

    it 'supports multiple imports' do
      ic = invoice_contract

      customer_contract = create_test_contract do
        object :contact do
          string :name
          string :email
        end
      end

      cc = customer_contract

      importing_contract = create_test_contract do
        import ic, as: :invoice
        import cc, as: :customer
      end

      expect(importing_contract.resolve_custom_type(:invoice_address)).not_to be_nil
      expect(importing_contract.resolve_custom_type(:customer_contact)).not_to be_nil
    end
  end

  describe 'Import validation' do
    it 'raises ConfigurationError for string argument' do
      expect do
        create_test_contract do
          import 'InvoiceContract', as: :invoice
        end
      end.to raise_error(Apiwork::ConfigurationError, /import must be a Class constant/)
    end

    it 'raises ConfigurationError for non-Contract class' do
      not_a_contract = Class.new

      expect do
        create_test_contract do
          import not_a_contract, as: :other
        end
      end.to raise_error(Apiwork::ConfigurationError, /import must be a Contract class/)
    end

    it 'raises ConfigurationError for non-Symbol alias' do
      ic = create_test_contract

      expect do
        create_test_contract do
          import ic, as: 'invoice'
        end
      end.to raise_error(Apiwork::ConfigurationError, /import alias must be a Symbol/)
    end
  end

  describe 'Type resolution priority' do
    it 'prefers local types over imported types' do
      base_contract = create_test_contract do
        object :metadata do
          integer :version
        end
      end

      bc = base_contract

      importing_contract = create_test_contract do
        import bc, as: :base

        object :metadata do
          string :version
        end
      end

      local_type = importing_contract.resolve_custom_type(:metadata)
      expect(local_type).not_to be_nil

      imported_type = importing_contract.resolve_custom_type(:base_metadata)
      expect(imported_type).not_to be_nil
    end
  end
end
