# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Date do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(enum: %w[1990-01-15], type: :date)

      expect(param.enum).to eq(%w[1990-01-15])
    end
  end

  describe '#date?' do
    it 'returns true when date' do
      expect(described_class.new(type: :date).date?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: %w[1990-01-15], type: :date)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :date)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :milestone, type: :date)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: %w[1990-01-15], type: :date)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :date).formattable?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :date).scalar?).to be(true)
    end
  end
end
