# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Configuration do
  describe '#method_missing' do
    context 'when option is unknown' do
      it 'raises ConfigurationError' do
        options = {
          strategy: Apiwork::Configuration::Option.new(:strategy, :symbol, default: :offset),
        }
        config = described_class.new(options)

        expect do
          config.unknown_option
        end.to raise_error(Apiwork::ConfigurationError, /Unknown option/)
      end
    end

    context 'when reading a non-nested option' do
      it 'returns the default' do
        options = {
          strategy: Apiwork::Configuration::Option.new(:strategy, :symbol, default: :offset),
        }
        config = described_class.new(options)

        expect(config.strategy).to eq(:offset)
      end
    end

    context 'when reading a nested option' do
      it 'returns the nested configuration' do
        options = {
          pagination: Apiwork::Configuration::Option.new(:pagination, :hash) do
            option :strategy, default: :offset, type: :symbol
          end,
        }
        config = described_class.new(options)

        expect(config.pagination).to be_a(described_class)
      end
    end

    context 'when setting a value' do
      it 'stores the value' do
        options = {
          strategy: Apiwork::Configuration::Option.new(:strategy, :symbol, default: :offset, enum: %i[offset cursor]),
        }
        config = described_class.new(options)
        config.strategy(:cursor)

        expect(config.strategy).to eq(:cursor)
      end
    end

    context 'when setting a nested value with block' do
      it 'yields the nested configuration' do
        options = {
          pagination: Apiwork::Configuration::Option.new(:pagination, :hash) do
            option :strategy, default: :offset, enum: %i[offset cursor], type: :symbol
          end,
        }
        config = described_class.new(options)
        config.pagination { strategy :cursor }

        expect(config.pagination.strategy).to eq(:cursor)
      end
    end
  end

  describe '#dig' do
    it 'returns the value' do
      options = {
        pagination: Apiwork::Configuration::Option.new(:pagination, :hash) do
          option :strategy, default: :offset, type: :symbol
        end,
      }
      config = described_class.new(options)

      expect(config.dig(:pagination, :strategy)).to eq(:offset)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      options = {
        pagination: Apiwork::Configuration::Option.new(:pagination, :hash) do
          option :strategy, default: :offset, type: :symbol
          option :default_size, default: 20, type: :integer
        end,
      }
      config = described_class.new(options)

      expect(config.to_h).to eq(
        {
          pagination: { default_size: 20, strategy: :offset },
        },
      )
    end
  end
end
