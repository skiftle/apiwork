# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Element do
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

      expect { element.object }.to raise_error(Apiwork::ConfigurationError, 'object requires a block')
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
      expect(element.item_type).to eq(:object)
      expect(element.shape).to be_a(Apiwork::API::Object)
    end

    it 'creates an array of primitives' do
      element = described_class.new
      element.array do
        string
      end

      expect(element.type).to eq(:array)
      expect(element.item_type).to eq(:string)
      expect(element.shape).to be_nil
    end

    it 'raises without block' do
      element = described_class.new

      expect { element.array }.to raise_error(Apiwork::ConfigurationError, 'array requires a block')
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

      expect { element.union }.to raise_error(Apiwork::ConfigurationError, 'union requires a block')
    end
  end

  describe '#validate!' do
    it 'raises if no type defined' do
      element = described_class.new

      expect { element.validate! }.to raise_error(
        Apiwork::ConfigurationError,
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

  describe '#item_type' do
    it 'returns nil for object' do
      element = described_class.new
      element.object do
        string :name
      end

      expect(element.item_type).to be_nil
    end

    it 'returns element type for array' do
      element = described_class.new
      element.array do
        integer
      end

      expect(element.item_type).to eq(:integer)
    end
  end

  describe '#inner' do
    it 'returns nil for object' do
      element = described_class.new
      element.object do
        string :name
      end

      expect(element.inner).to be_nil
    end

    it 'returns inner element for array' do
      element = described_class.new
      element.array do
        string
      end

      expect(element.inner).to be_a(Apiwork::API::Element)
      expect(element.inner.type).to eq(:string)
    end

    it 'preserves constraints on inner element' do
      element = described_class.new
      element.array do
        string max: 100, min: 1
      end

      expect(element.inner.min).to eq(1)
      expect(element.inner.max).to eq(100)
    end
  end

  describe 'nested arrays' do
    it 'creates array of arrays' do
      element = described_class.new
      element.array do
        array do
          string
        end
      end

      expect(element.type).to eq(:array)
      expect(element.item_type).to eq(:array)
      expect(element.inner.type).to eq(:array)
      expect(element.inner.item_type).to eq(:string)
    end

    it 'preserves constraints through nested arrays' do
      element = described_class.new
      element.array do
        array do
          integer max: 100, min: 0
        end
      end

      inner_inner = element.inner.inner

      expect(inner_inner.type).to eq(:integer)
      expect(inner_inner.min).to eq(0)
      expect(inner_inner.max).to eq(100)
    end

    it 'creates deeply nested arrays' do
      element = described_class.new
      element.array do
        array do
          array do
            string format: :email
          end
        end
      end

      level1 = element.inner
      level2 = level1.inner
      level3 = level2.inner

      expect(level1.type).to eq(:array)
      expect(level2.type).to eq(:array)
      expect(level3.type).to eq(:string)
      expect(level3.format).to eq(:email)
    end

    it 'creates array of arrays of objects' do
      element = described_class.new
      element.array do
        array do
          object do
            string :name
            integer :age
          end
        end
      end

      expect(element.type).to eq(:array)
      expect(element.item_type).to eq(:array)
      expect(element.inner.item_type).to eq(:object)
      expect(element.inner.inner.shape).to be_a(Apiwork::API::Object)
      expect(element.inner.inner.shape.params.keys).to eq(%i[name age])
    end
  end
end
