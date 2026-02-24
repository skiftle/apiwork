# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Configuration::Option do
  describe '#initialize' do
    it 'creates with required attributes' do
      option = described_class.new(:strategy, :symbol)

      expect(option.name).to eq(:strategy)
      expect(option.type).to eq(:symbol)
      expect(option.default).to be_nil
      expect(option.enum).to be_nil
      expect(option.children).to eq({})
    end

    it 'accepts default and enum' do
      option = described_class.new(:strategy, :symbol, default: :offset, enum: %i[offset cursor])

      expect(option.default).to eq(:offset)
      expect(option.enum).to eq(%i[offset cursor])
    end
  end

  describe '#option' do
    it 'registers the option' do
      parent = described_class.new(:pagination, :hash)
      parent.option(:strategy, default: :offset, type: :symbol)

      expect(parent.children[:strategy]).to be_a(described_class)
      expect(parent.children[:strategy].name).to eq(:strategy)
      expect(parent.children[:strategy].default).to eq(:offset)
    end
  end

  describe '#cast' do
    context 'when value is nil' do
      it 'returns nil' do
        option = described_class.new(:strategy, :symbol)

        expect(option.cast(nil)).to be_nil
      end
    end

    context 'when value is not a String' do
      it 'returns the value unchanged' do
        option = described_class.new(:strategy, :symbol)

        expect(option.cast(:offset)).to eq(:offset)
      end
    end

    context 'when type is :symbol' do
      it 'returns the symbol' do
        option = described_class.new(:strategy, :symbol)

        expect(option.cast('offset')).to eq(:offset)
      end
    end

    context 'when type is :string' do
      it 'returns the string' do
        option = described_class.new(:title, :string)

        expect(option.cast('First Post')).to eq('First Post')
      end
    end

    context 'when type is :integer' do
      it 'returns the integer' do
        option = described_class.new(:default_size, :integer)

        expect(option.cast('20')).to eq(20)
      end
    end

    context 'when type is :boolean' do
      it 'returns the boolean' do
        option = described_class.new(:enabled, :boolean)

        expect(option.cast('true')).to be(true)
      end
    end

    context 'when type is :hash' do
      it 'returns the value unchanged' do
        option = described_class.new(:pagination, :hash)

        expect(option.cast('value')).to eq('value')
      end
    end
  end

  describe '#validate!' do
    context 'when value is nil' do
      it 'returns nil' do
        option = described_class.new(:strategy, :symbol)

        expect(option.validate!(nil)).to be_nil
      end
    end

    context 'when nested and value is not a Hash' do
      it 'raises ConfigurationError' do
        option = described_class.new(:pagination, :hash)
        option.option(:strategy, default: :offset, type: :symbol)

        expect do
          option.validate!('invalid')
        end.to raise_error(Apiwork::ConfigurationError, /must be a Hash/)
      end
    end

    context 'when nested and value is a Hash' do
      it 'raises ConfigurationError when key is unknown' do
        option = described_class.new(:pagination, :hash)
        option.option(:strategy, default: :offset, type: :symbol)

        expect do
          option.validate!({ unknown_key: :value })
        end.to raise_error(Apiwork::ConfigurationError, /Unknown option/)
      end
    end

    context 'when not nested and type is wrong' do
      it 'raises ConfigurationError' do
        option = described_class.new(:default_size, :integer)

        expect do
          option.validate!('not_an_integer')
        end.to raise_error(Apiwork::ConfigurationError)
      end
    end

    context 'when not nested and value is not in enum' do
      it 'raises ConfigurationError' do
        option = described_class.new(:strategy, :symbol, enum: %i[offset cursor])

        expect do
          option.validate!(:invalid)
        end.to raise_error(Apiwork::ConfigurationError)
      end
    end
  end
end
