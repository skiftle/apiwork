# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Configuration do
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
