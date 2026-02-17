# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Element do
  describe '#array' do
    it 'sets the type to array' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.array do
        string
      end

      expect(element.type).to eq(:array)
    end
  end

  describe '#binary' do
    it 'sets the type to binary' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.binary

      expect(element.type).to eq(:binary)
    end
  end

  describe '#boolean' do
    it 'sets the type to boolean' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.boolean

      expect(element.type).to eq(:boolean)
    end
  end

  describe '#date' do
    it 'sets the type to date' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.date

      expect(element.type).to eq(:date)
    end
  end

  describe '#datetime' do
    it 'sets the type to datetime' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.datetime

      expect(element.type).to eq(:datetime)
    end
  end

  describe '#decimal' do
    it 'sets the type to decimal' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.decimal

      expect(element.type).to eq(:decimal)
    end
  end

  describe '#integer' do
    it 'sets the type to integer' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.integer

      expect(element.type).to eq(:integer)
    end
  end

  describe '#literal' do
    it 'sets the type to literal' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.literal(value: '1.0')

      expect(element.type).to eq(:literal)
    end
  end

  describe '#number' do
    it 'sets the type to number' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.number

      expect(element.type).to eq(:number)
    end
  end

  describe '#object' do
    it 'sets the type to object' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.object do
        string :title
      end

      expect(element.type).to eq(:object)
      expect(element.shape).to be_a(Apiwork::Contract::Object)
    end
  end

  describe '#of' do
    context 'when type is a primitive' do
      it 'defines the type' do
        contract_class = create_test_contract
        element = described_class.new(contract_class)
        element.of(:string)

        expect(element.type).to eq(:string)
      end
    end

    context 'when type is :object' do
      it 'sets the type and shape' do
        contract_class = create_test_contract
        element = described_class.new(contract_class)
        element.of(:object) do
          string :title
        end

        expect(element.type).to eq(:object)
        expect(element.shape).to be_a(Apiwork::Contract::Object)
      end
    end

    context 'when type is a custom reference' do
      it 'sets the custom type' do
        contract_class = create_test_contract do
          object :item do
            string :title
          end
        end
        element = described_class.new(contract_class)
        element.of(:item)

        expect(element.type).to eq(:item)
        expect(element.custom_type).to eq(:item)
      end
    end
  end

  describe '#reference' do
    it 'sets the custom type' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.reference(:item)

      expect(element.type).to eq(:item)
      expect(element.custom_type).to eq(:item)
    end
  end

  describe '#string' do
    it 'sets the type to string' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.string

      expect(element.type).to eq(:string)
    end
  end

  describe '#time' do
    it 'sets the type to time' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.time

      expect(element.type).to eq(:time)
    end
  end

  describe '#union' do
    it 'sets the type to union' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.union(discriminator: :type) do
        variant tag: 'card' do
          object do
            string :last_four
          end
        end
      end

      expect(element.type).to eq(:union)
    end
  end

  describe '#uuid' do
    it 'sets the type to uuid' do
      contract_class = create_test_contract
      element = described_class.new(contract_class)
      element.uuid

      expect(element.type).to eq(:uuid)
    end
  end
end
