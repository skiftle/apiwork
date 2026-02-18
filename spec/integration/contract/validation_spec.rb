# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract validation', type: :integration do
  describe 'Type validation' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              string :number
              integer :quantity
              boolean :sent
              uuid :reference_id
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'accepts valid string value' do
      result = shape.validate({ number: 'INV-001', quantity: 10, reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: true })

      expect(result).to be_valid
      expect(result.params[:number]).to eq('INV-001')
    end

    it 'rejects integer for string param' do
      result = shape.validate({ number: 42, quantity: 10, reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: true })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:type_invalid)
      expect(result.issues.first.meta[:expected]).to eq(:string)
    end

    it 'accepts valid integer value' do
      result = shape.validate({ number: 'INV-001', quantity: 10, reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: true })

      expect(result).to be_valid
      expect(result.params[:quantity]).to eq(10)
    end

    it 'rejects string for integer param' do
      result = shape.validate({ number: 'INV-001', quantity: 'ten', reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: true })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:type_invalid)
      expect(result.issues.first.meta[:expected]).to eq(:integer)
    end

    it 'accepts valid boolean value' do
      result = shape.validate({ number: 'INV-001', quantity: 10, reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: false })

      expect(result).to be_valid
      expect(result.params[:sent]).to be(false)
    end

    it 'rejects string for boolean param' do
      result = shape.validate({ number: 'INV-001', quantity: 10, reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: 'yes' })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:type_invalid)
      expect(result.issues.first.meta[:expected]).to eq(:boolean)
    end

    it 'accepts valid UUID string' do
      result = shape.validate({ number: 'INV-001', quantity: 10, reference_id: '550e8400-e29b-41d4-a716-446655440000', sent: true })

      expect(result).to be_valid
    end

    it 'rejects non-UUID string' do
      result = shape.validate({ number: 'INV-001', quantity: 10, reference_id: 'not-a-uuid', sent: true })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:type_invalid)
    end
  end

  describe 'Required and optional params' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              string :number
              string? :notes
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'rejects missing required param' do
      result = shape.validate({})

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:field_missing)
      expect(result.issues.first.meta[:field]).to eq(:number)
    end

    it 'accepts missing optional param' do
      result = shape.validate({ number: 'INV-001' })

      expect(result).to be_valid
    end
  end

  describe 'Nullable params' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              string :notes, nullable: true
              string? :description
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'accepts null for nullable param' do
      result = shape.validate({ notes: nil })

      expect(result).to be_valid
    end

    it 'rejects null for non-nullable param' do
      result = shape.validate({ description: nil, notes: 'Rush delivery' })

      expect(result).to be_invalid
      expect(result.issues.first.code).to eq(:value_null)
    end
  end

  describe 'Unknown fields and error reporting' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              string :number
              integer :quantity
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'rejects unknown fields' do
      result = shape.validate({ nonexistent: 'value', number: 'INV-001', quantity: 10 })

      expect(result).to be_invalid
      issue = result.issues.find { |i| i.code == :field_unknown }
      expect(issue.meta[:field]).to eq(:nonexistent)
    end

    it 'reports multiple validation errors at once' do
      result = shape.validate({})

      expect(result).to be_invalid
      codes = result.issues.map(&:code)
      expect(codes).to include(:field_missing)
      expect(result.issues.length).to eq(2)
    end

    it 'includes code, detail, path, and meta on each issue' do
      result = shape.validate({})

      issue = result.issues.first
      expect(issue.code).to eq(:field_missing)
      expect(issue.detail).to eq('Required')
      expect(issue.path).to eq([:number])
      expect(issue.meta[:field]).to eq(:number)
    end
  end
end
