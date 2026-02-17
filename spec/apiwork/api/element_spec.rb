# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Element do
  describe '#array' do
    it 'sets the type to array' do
      element = described_class.new
      element.array do
        string
      end

      expect(element.type).to eq(:array)
    end
  end

  describe '#binary' do
    it 'sets the type to binary' do
      element = described_class.new
      element.binary

      expect(element.type).to eq(:binary)
    end
  end

  describe '#boolean' do
    it 'sets the type to boolean' do
      element = described_class.new
      element.boolean

      expect(element.type).to eq(:boolean)
    end
  end

  describe '#date' do
    it 'sets the type to date' do
      element = described_class.new
      element.date

      expect(element.type).to eq(:date)
    end
  end

  describe '#datetime' do
    it 'sets the type to datetime' do
      element = described_class.new
      element.datetime

      expect(element.type).to eq(:datetime)
    end
  end

  describe '#decimal' do
    it 'sets the type to decimal' do
      element = described_class.new
      element.decimal

      expect(element.type).to eq(:decimal)
    end
  end

  describe '#integer' do
    it 'sets the type to integer' do
      element = described_class.new
      element.integer

      expect(element.type).to eq(:integer)
    end
  end

  describe '#literal' do
    it 'sets the type to literal' do
      element = described_class.new
      element.literal(value: '1.0')

      expect(element.type).to eq(:literal)
    end
  end

  describe '#number' do
    it 'sets the type to number' do
      element = described_class.new
      element.number

      expect(element.type).to eq(:number)
    end
  end

  describe '#object' do
    it 'sets the type to object' do
      element = described_class.new
      element.object do
        string :title
      end

      expect(element.type).to eq(:object)
      expect(element.shape).to be_a(Apiwork::API::Object)
    end
  end

  describe '#of' do
    context 'when type is a primitive' do
      it 'defines the type' do
        element = described_class.new
        element.of(:string)

        expect(element.type).to eq(:string)
      end
    end

    context 'when type is :object' do
      it 'sets the type and shape' do
        element = described_class.new
        element.of(:object) do
          string :title
        end

        expect(element.type).to eq(:object)
        expect(element.shape).to be_a(Apiwork::API::Object)
      end
    end

    context 'when type is a custom reference' do
      it 'sets the custom type' do
        element = described_class.new
        element.of(:item)

        expect(element.type).to eq(:item)
        expect(element.custom_type).to eq(:item)
      end
    end
  end

  describe '#reference' do
    it 'sets the custom type' do
      element = described_class.new
      element.reference(:item)

      expect(element.type).to eq(:item)
      expect(element.custom_type).to eq(:item)
    end
  end

  describe '#string' do
    it 'sets the type to string' do
      element = described_class.new
      element.string

      expect(element.type).to eq(:string)
    end
  end

  describe '#time' do
    it 'sets the type to time' do
      element = described_class.new
      element.time

      expect(element.type).to eq(:time)
    end
  end

  describe '#union' do
    it 'sets the type to union' do
      element = described_class.new
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
      element = described_class.new
      element.uuid

      expect(element.type).to eq(:uuid)
    end
  end
end
