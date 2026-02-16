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
end
