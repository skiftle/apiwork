# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Element do
  describe '#array' do
    it 'defines the type' do
      element = described_class.new
      element.array do
        string
      end

      expect(element.type).to eq(:array)
    end
  end

  describe '#binary' do
    it 'defines the type' do
      element = described_class.new
      element.binary

      expect(element.type).to eq(:binary)
    end
  end

  describe '#boolean' do
    it 'defines the type' do
      element = described_class.new
      element.boolean

      expect(element.type).to eq(:boolean)
    end
  end

  describe '#date' do
    it 'defines the type' do
      element = described_class.new
      element.date

      expect(element.type).to eq(:date)
    end
  end

  describe '#datetime' do
    it 'defines the type' do
      element = described_class.new
      element.datetime

      expect(element.type).to eq(:datetime)
    end
  end

  describe '#decimal' do
    it 'defines the type' do
      element = described_class.new
      element.decimal

      expect(element.type).to eq(:decimal)
    end
  end

  describe '#integer' do
    it 'defines the type' do
      element = described_class.new
      element.integer

      expect(element.type).to eq(:integer)
    end
  end

  describe '#literal' do
    it 'defines the type' do
      element = described_class.new
      element.literal(value: '1.0')

      expect(element.type).to eq(:literal)
    end
  end

  describe '#number' do
    it 'defines the type' do
      element = described_class.new
      element.number

      expect(element.type).to eq(:number)
    end
  end

  describe '#object' do
    it 'defines the type' do
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
      it 'defines the element type' do
        element = described_class.new
        element.of(:string)

        expect(element.type).to eq(:string)
      end
    end

    context 'when type is :object' do
      it 'defines the element type and shape' do
        element = described_class.new
        element.of(:object) do
          string :title
        end

        expect(element.type).to eq(:object)
        expect(element.shape).to be_a(Apiwork::API::Object)
      end
    end

    context 'when type is :literal' do
      it 'defines the element type' do
        element = described_class.new
        element.of(:literal, value: '1.0')

        expect(element.type).to eq(:literal)
      end
    end

    context 'when type is :array' do
      it 'defines the element type' do
        element = described_class.new
        element.of(:array) { string }

        expect(element.type).to eq(:array)
      end
    end

    context 'when type is :union' do
      it 'defines the element type' do
        element = described_class.new
        element.of(:union, discriminator: :type) do
          variant tag: 'card' do
            object { string :last_four }
          end
        end

        expect(element.type).to eq(:union)
      end
    end

    context 'when type is a custom reference' do
      it 'defines the custom type' do
        element = described_class.new
        element.of(:item)

        expect(element.type).to eq(:item)
        expect(element.custom_type).to eq(:item)
      end
    end
  end

  describe '#reference' do
    it 'defines the custom type' do
      element = described_class.new
      element.reference(:item)

      expect(element.type).to eq(:item)
      expect(element.custom_type).to eq(:item)
    end
  end

  describe '#string' do
    it 'defines the type' do
      element = described_class.new
      element.string

      expect(element.type).to eq(:string)
    end
  end

  describe '#time' do
    it 'defines the type' do
      element = described_class.new
      element.time

      expect(element.type).to eq(:time)
    end
  end

  describe '#union' do
    it 'defines the type' do
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
    it 'defines the type' do
      element = described_class.new
      element.uuid

      expect(element.type).to eq(:uuid)
    end
  end
end
