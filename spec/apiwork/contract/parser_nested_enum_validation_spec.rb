# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Parser Nested Custom Type Enum Validation' do
  before do
    TestApiHelper.api_class.type_system.clear!
  end

  describe 'output validation with nested custom types' do
    it 'validates enum values in nested custom types' do
      contract_class = create_test_contract do
        type :account do
          param :id, required: true, type: :integer
          param :name, required: true, type: :string
          param :status, enum: %w[active inactive archived], required: true, type: :string
          param :first_day_of_week, enum: %w[monday tuesday wednesday thursday friday saturday sunday], required: false, type: :string
        end

        action :show do
          response do
            body do
              param :account, required: true, type: :account
            end
          end
        end
      end

      # Valid nested enum values should pass
      valid_output = {
        account: {
          id: 1,
          name: 'Test Account',
          status: 'active',
          first_day_of_week: 'monday',
        },
      }
      result = contract_class.parse_response(valid_output, :show)
      expect(result.valid?).to be(true), "Expected valid result but got issues: #{result.issues.inspect}"

      # Invalid status enum should fail
      invalid_status = {
        account: {
          id: 1,
          name: 'Test Account',
          status: 'deleted', # Not in enum
          first_day_of_week: 'monday',
        },
      }
      result = contract_class.parse_response(invalid_status, :show)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:value_invalid)
      expect(result.issues.first.detail).to eq('Invalid value')
      expect(result.issues.first.path).to eq([:account, :status])

      # Invalid first_day_of_week enum should fail
      invalid_fdow = {
        account: {
          id: 1,
          name: 'Test Account',
          status: 'active',
          first_day_of_week: 'hahahahahaha', # Not in enum
        },
      }
      result = contract_class.parse_response(invalid_fdow, :show)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:value_invalid)
      expect(result.issues.first.detail).to eq('Invalid value')
      expect(result.issues.first.path).to eq([:account, :first_day_of_week])
    end

    it 'validates type errors in nested custom types without coercion' do
      contract_class = create_test_contract do
        type :account do
          param :id, required: true, type: :integer
          param :name, required: true, type: :string
        end

        action :show do
          response do
            body do
              param :account, required: true, type: :account
            end
          end
        end
      end

      # Wrong type (number instead of string) should fail WITHOUT coercion
      invalid_output = {
        account: {
          id: 1,
          name: 42, # Should be string
        },
      }
      result = contract_class.parse_response(invalid_output, :show)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:type_invalid)
      expect(result.issues.first.path).to eq([:account, :name])
    end

    it 'validates deeply nested custom types' do
      contract_class = create_test_contract do
        type :address do
          param :city, required: true, type: :string
          param :country_code, enum: %w[US UK SE], required: true, type: :string
        end

        type :account do
          param :id, required: true, type: :integer
          param :address, required: true, type: :address
        end

        action :show do
          response do
            body do
              param :account, required: true, type: :account
            end
          end
        end
      end

      # Invalid enum in deeply nested object
      invalid_output = {
        account: {
          id: 1,
          address: {
            city: 'Stockholm',
            country_code: 'INVALID', # Not in enum
          },
        },
      }
      result = contract_class.parse_response(invalid_output, :show)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:value_invalid)
      expect(result.issues.first.path).to eq([:account, :address, :country_code])
    end
  end
end
