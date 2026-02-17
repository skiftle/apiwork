# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object::Coercer do
  describe '#coerce' do
    it 'returns the coerced hash' do
      contract_class = create_test_contract do
        action :create do
          request do
            query do
              integer :amount
            end
          end
        end
      end
      shape = contract_class.action_for(:create).request.query
      coercer = described_class.new(shape)

      result = coercer.coerce({ amount: '42' })

      expect(result).to eq({ amount: 42 })
    end

    context 'with boolean values' do
      it 'returns the coerced hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              query do
                boolean :active
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.query
        coercer = described_class.new(shape)

        result = coercer.coerce({ active: 'true' })

        expect(result).to eq({ active: true })
      end
    end

    context 'when value is already the correct type' do
      it 'returns the value unchanged' do
        contract_class = create_test_contract do
          action :create do
            request do
              query do
                integer :amount
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.query
        coercer = described_class.new(shape)

        result = coercer.coerce({ amount: 42 })

        expect(result).to eq({ amount: 42 })
      end
    end

    context 'with nested object' do
      it 'returns the coerced hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                param :address, type: :object do
                  integer :amount
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        coercer = described_class.new(shape)

        result = coercer.coerce({ address: { amount: '42' } })

        expect(result).to eq({ address: { amount: 42 } })
      end
    end

    context 'with array of primitives' do
      it 'returns the coerced hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              body do
                array :items do
                  integer
                end
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.body
        coercer = described_class.new(shape)

        result = coercer.coerce({ items: %w[1 2 3] })

        expect(result).to eq({ items: [1, 2, 3] })
      end
    end

    context 'when key is not present in hash' do
      it 'returns an empty hash' do
        contract_class = create_test_contract do
          action :create do
            request do
              query do
                integer :amount
              end
            end
          end
        end
        shape = contract_class.action_for(:create).request.query
        coercer = described_class.new(shape)

        result = coercer.coerce({})

        expect(result).to eq({})
      end
    end
  end
end
