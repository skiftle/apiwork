# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Parser Nested Custom Type Enum Validation' do
  describe 'output validation with nested custom types' do
    it 'validates enum values in nested custom types' do
      contract_class = create_test_contract do
        object :account do
          integer :id
          string :name
          string :status, enum: %w[active inactive archived]
          string :first_day_of_week, enum: %w[monday tuesday wednesday thursday friday saturday sunday], optional: true
        end

        action :show do
          response do
            body do
              reference :account
            end
          end
        end
      end

      # Valid nested enum values should pass
      valid_output = {
        account: {
          first_day_of_week: 'monday',
          id: 1,
          name: 'Test Account',
          status: 'active',
        },
      }
      result = contract_class.parse_response(valid_output, :show)
      expect(result.valid?).to be(true), "Expected valid result but got issues: #{result.issues.inspect}"

      # Invalid status enum should fail
      invalid_status = {
        account: {
          first_day_of_week: 'monday',
          id: 1,
          name: 'Test Account',
          status: 'deleted',
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
          first_day_of_week: 'hahahahahaha',
          id: 1,
          name: 'Test Account',
          status: 'active',
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
        object :account do
          integer :id
          string :name
        end

        action :show do
          response do
            body do
              reference :account
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
        object :address do
          string :city
          string :country_code, enum: %w[US UK SE]
        end

        object :account do
          integer :id
          reference :address
        end

        action :show do
          response do
            body do
              reference :account
            end
          end
        end
      end

      # Invalid enum in deeply nested object
      invalid_output = {
        account: {
          address: {
            city: 'Stockholm',
            country_code: 'INVALID', # Not in enum
          },
          id: 1,
        },
      }
      result = contract_class.parse_response(invalid_output, :show)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:value_invalid)
      expect(result.issues.first.path).to eq([:account, :address, :country_code])
    end
  end
end
