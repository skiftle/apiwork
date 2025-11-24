# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Parser Nested Custom Type Enum Validation' do
  describe 'output validation with nested custom types' do
    it 'validates enum values in nested custom types' do
      # Define a custom type with enum
      contract_class = Class.new(Apiwork::Contract::Base) do
        # Register custom type for account
        type :account do
          param :id, type: :integer, required: true
          param :name, type: :string, required: true
          param :status, type: :string, enum: %w[active inactive archived], required: true
          param :first_day_of_week, type: :string, enum: %w[monday tuesday wednesday thursday friday saturday sunday], required: false
        end

        action :show do
          response do
            body do
              param :account, type: :account, required: true
            end
          end
        end
      end

      parser = Apiwork::Contract::Parser.new(contract_class, :response_body, :show, coerce: false)

      # Valid nested enum values should pass
      valid_output = {
        account: {
          id: 1,
          name: 'Test Account',
          status: 'active',
          first_day_of_week: 'monday'
        }
      }
      result = parser.perform(valid_output)
      expect(result.valid?).to be(true), "Expected valid result but got issues: #{result.issues.inspect}"

      # Invalid status enum should fail
      invalid_status = {
        account: {
          id: 1,
          name: 'Test Account',
          status: 'deleted', # Not in enum
          first_day_of_week: 'monday'
        }
      }
      result = parser.perform(invalid_status)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:invalid_value)
      expect(result.issues.first.detail).to include('Must be one of')
      expect(result.issues.first.path).to eq([:account, :status])

      # Invalid first_day_of_week enum should fail
      invalid_fdow = {
        account: {
          id: 1,
          name: 'Test Account',
          status: 'active',
          first_day_of_week: 'hahahahahaha' # Not in enum
        }
      }
      result = parser.perform(invalid_fdow)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:invalid_value)
      expect(result.issues.first.detail).to include('Must be one of')
      expect(result.issues.first.path).to eq([:account, :first_day_of_week])
    end

    it 'validates type errors in nested custom types without coercion' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        type :account do
          param :id, type: :integer, required: true
          param :name, type: :string, required: true
        end

        action :show do
          response do
            body do
              param :account, type: :account, required: true
            end
          end
        end
      end

      parser = Apiwork::Contract::Parser.new(contract_class, :response_body, :show, coerce: false)

      # Wrong type (number instead of string) should fail WITHOUT coercion
      invalid_output = {
        account: {
          id: 1,
          name: 42 # Should be string
        }
      }
      result = parser.perform(invalid_output)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:invalid_type)
      expect(result.issues.first.path).to eq([:account, :name])
    end

    it 'validates deeply nested custom types' do
      contract_class = Class.new(Apiwork::Contract::Base) do
        # Nested custom type
        type :address do
          param :city, type: :string, required: true
          param :country, type: :string, enum: %w[US UK SE], required: true
        end

        type :account do
          param :id, type: :integer, required: true
          param :address, type: :address, required: true
        end

        action :show do
          response do
            body do
              param :account, type: :account, required: true
            end
          end
        end
      end

      parser = Apiwork::Contract::Parser.new(contract_class, :response_body, :show, coerce: false)

      # Invalid enum in deeply nested object
      invalid_output = {
        account: {
          id: 1,
          address: {
            city: 'Stockholm',
            country: 'INVALID' # Not in enum
          }
        }
      }
      result = parser.perform(invalid_output)
      expect(result.invalid?).to be(true)
      expect(result.issues.first.code).to eq(:invalid_value)
      expect(result.issues.first.path).to eq([:account, :address, :country])
    end
  end
end
