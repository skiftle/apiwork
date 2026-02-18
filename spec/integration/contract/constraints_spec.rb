# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract constraints', type: :integration do
  describe 'String length constraints' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              string :number, max: 10, min: 3
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'accepts string within length bounds' do
      result = shape.validate({ number: 'INV-001' })

      expect(result).to be_valid
    end

    it 'rejects string shorter than minimum' do
      result = shape.validate({ number: 'IN' })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:string_too_short)
      expect(result.issues.first.meta[:min]).to eq(3)
    end

    it 'rejects string longer than maximum' do
      result = shape.validate({ number: 'INV-001-EXTENDED' })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:string_too_long)
      expect(result.issues.first.meta[:max]).to eq(10)
    end
  end

  describe 'Numeric range constraints' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              integer :quantity, max: 100, min: 1
              decimal :amount, max: 9999.99, min: 0.01
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'accepts values within range' do
      result = shape.validate({ amount: 150.00, quantity: 10 })

      expect(result).to be_valid
    end

    it 'rejects integer below minimum' do
      result = shape.validate({ amount: 150.00, quantity: 0 })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:number_too_small)
      expect(result.issues.first.meta[:min]).to eq(1)
    end

    it 'rejects integer above maximum' do
      result = shape.validate({ amount: 150.00, quantity: 101 })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:number_too_large)
      expect(result.issues.first.meta[:max]).to eq(100)
    end

    it 'rejects decimal below minimum' do
      result = shape.validate({ amount: 0.001, quantity: 10 })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:number_too_small)
    end

    it 'rejects decimal above maximum' do
      result = shape.validate({ amount: 10_000.00, quantity: 10 })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:number_too_large)
    end
  end

  describe 'Enum validation' do
    let(:contract_class) do
      create_test_contract do
        enum :invoice_status, values: %w[draft sent paid]

        action :update do
          request do
            body do
              string :priority, enum: %w[low medium high]
              string :status, enum: :invoice_status
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:update).request.body }

    it 'accepts valid enum values for both registered and inline enums' do
      result = shape.validate({ priority: 'high', status: 'draft' })

      expect(result).to be_valid
    end

    it 'rejects invalid registered enum value with expected values in meta' do
      result = shape.validate({ priority: 'high', status: 'cancelled' })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:value_invalid)
      expect(result.issues.first.meta[:expected]).to eq(%w[draft sent paid])
    end

    it 'rejects invalid inline enum value' do
      result = shape.validate({ priority: 'critical', status: 'draft' })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:value_invalid)
    end
  end

  describe 'Default values and array size constraints' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              string :notes, default: 'Net 30 payment terms', optional: true
              boolean :notify, default: true, optional: true
              param :items, max: 5, min: 2, of: :string, type: :array
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'applies defaults when values are absent' do
      result = shape.validate({ items: %w[Consulting Support] })

      expect(result).to be_valid
      expect(result.params[:notes]).to eq('Net 30 payment terms')
      expect(result.params[:notify]).to be(true)
    end

    it 'preserves provided value over default' do
      result = shape.validate({ items: %w[Consulting Support], notes: 'Rush delivery' })

      expect(result).to be_valid
      expect(result.params[:notes]).to eq('Rush delivery')
    end

    it 'rejects array smaller than minimum' do
      result = shape.validate({ items: %w[Consulting] })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:array_too_small)
    end

    it 'rejects array larger than maximum' do
      result = shape.validate({ items: %w[a b c d e f] })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:array_too_large)
    end
  end
end
