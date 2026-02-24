# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract coercion', type: :integration do
  describe 'Integer coercion' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              integer :quantity
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'coerces string to integer' do
      result = shape.coerce({ quantity: '10' })

      expect(result[:quantity]).to eq(10)
    end

    it 'preserves value when already an integer' do
      result = shape.coerce({ quantity: 10 })

      expect(result[:quantity]).to eq(10)
    end

    it 'preserves invalid string that cannot be coerced' do
      result = shape.coerce({ quantity: 'ten' })

      expect(result[:quantity]).to eq('ten')
    end
  end

  describe 'Boolean coercion' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              boolean :sent
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'coerces string "true" to boolean true' do
      result = shape.coerce({ sent: 'true' })

      expect(result[:sent]).to be(true)
    end

    it 'coerces string "false" to boolean false' do
      result = shape.coerce({ sent: 'false' })

      expect(result[:sent]).to be(false)
    end

    it 'coerces string "1" to boolean true' do
      result = shape.coerce({ sent: '1' })

      expect(result[:sent]).to be(true)
    end

    it 'coerces string "0" to boolean false' do
      result = shape.coerce({ sent: '0' })

      expect(result[:sent]).to be(false)
    end
  end

  describe 'Decimal coercion' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              decimal :amount
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'coerces string to decimal' do
      result = shape.coerce({ amount: '150.00' })

      expect(result[:amount]).to eq(BigDecimal('150.00'))
    end

    it 'coerces integer to decimal' do
      result = shape.coerce({ amount: 150 })

      expect(result[:amount]).to eq(BigDecimal('150'))
    end
  end

  describe 'Temporal coercion' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              date :due_on
              datetime :sent_at
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'coerces string to date' do
      result = shape.coerce({ due_on: '2026-03-15', sent_at: Time.zone.now })

      expect(result[:due_on]).to eq(Date.new(2026, 3, 15))
    end

    it 'coerces string to datetime' do
      result = shape.coerce({ due_on: Date.current, sent_at: '2026-03-15T10:30:00Z' })

      expect(result[:sent_at].year).to eq(2026)
      expect(result[:sent_at].month).to eq(3)
    end
  end

  describe 'Nested and array coercion' do
    let(:contract_class) do
      create_test_contract do
        action :create do
          request do
            body do
              param :address, type: :object do
                string :city
                integer :zip
              end
              array :quantities do
                integer
              end
            end
          end
        end
      end
    end

    let(:shape) { contract_class.action_for(:create).request.body }

    it 'coerces values inside nested objects' do
      result = shape.coerce({ address: { city: 'Stockholm', zip: '11122' }, quantities: [1] })

      expect(result[:address][:zip]).to eq(11_122)
      expect(result[:address][:city]).to eq('Stockholm')
    end

    it 'coerces each element in an array' do
      result = shape.coerce({ address: { city: 'Stockholm', zip: 11_122 }, quantities: %w[1 2 3] })

      expect(result[:quantities]).to eq([1, 2, 3])
    end
  end
end
