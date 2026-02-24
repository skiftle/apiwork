# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Time do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(enum: %w[09:00 17:00], type: :time)

      expect(param.enum).to eq(%w[09:00 17:00])
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: %w[09:00 17:00], type: :time)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :time)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :schedule, type: :time)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: %w[09:00 17:00], type: :time)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :time).formattable?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :time).scalar?).to be(true)
    end
  end

  describe '#time?' do
    it 'returns true when time' do
      expect(described_class.new(type: :time).time?).to be(true)
    end
  end
end
