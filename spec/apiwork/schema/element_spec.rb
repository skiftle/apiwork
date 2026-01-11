# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Schema::Element do
  describe '#object' do
    it 'creates an object element' do
      element = described_class.new
      element.object do
        string :name
      end

      expect(element.type).to eq(:object)
      expect(element.shape).to be_a(Apiwork::API::Object)
      expect(element.shape.params.keys).to eq([:name])
    end

    it 'raises without block' do
      element = described_class.new

      expect { element.object }.to raise_error(ArgumentError, 'object requires a block')
    end
  end

  describe '#array' do
    it 'creates an array of objects' do
      element = described_class.new
      element.array do
        object do
          string :street
        end
      end

      expect(element.type).to eq(:array)
      expect(element.of_type).to eq(:object)
      expect(element.shape).to be_a(Apiwork::API::Object)
    end

    it 'creates an array of primitives' do
      element = described_class.new
      element.array do
        string
      end

      expect(element.type).to eq(:array)
      expect(element.of_type).to eq(:string)
      expect(element.shape).to be_nil
    end

    it 'raises without block' do
      element = described_class.new

      expect { element.array }.to raise_error(ArgumentError, 'array requires a block')
    end
  end

  describe '#union' do
    it 'creates a union with discriminator' do
      element = described_class.new
      element.union discriminator: :type do
        variant tag: 'a' do
          object do
            string :value
          end
        end
      end

      expect(element.type).to eq(:union)
      expect(element.discriminator).to eq(:type)
      expect(element.shape).to be_a(Apiwork::API::Union)
    end

    it 'raises without block' do
      element = described_class.new

      expect { element.union }.to raise_error(ArgumentError, 'union requires a block')
    end
  end

  describe '#validate!' do
    it 'raises if no type defined' do
      element = described_class.new

      expect { element.validate! }.to raise_error(
        ArgumentError,
        'must define exactly one type (object, array, or union)',
      )
    end

    it 'passes when type is defined' do
      element = described_class.new
      element.object do
        string :name
      end

      expect { element.validate! }.not_to raise_error
    end
  end

  describe '#of_type' do
    it 'returns nil for object' do
      element = described_class.new
      element.object do
        string :name
      end

      expect(element.of_type).to be_nil
    end

    it 'returns element type for array' do
      element = described_class.new
      element.array do
        integer
      end

      expect(element.of_type).to eq(:integer)
    end
  end

  describe '#of_value' do
    it 'returns the same as of_type' do
      element = described_class.new
      element.array do
        string
      end

      expect(element.of_value).to eq(element.of_type)
    end
  end
end
