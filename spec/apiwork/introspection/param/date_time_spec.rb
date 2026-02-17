# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::DateTime do
  describe '#datetime?' do
    it 'returns true when datetime' do
      expect(described_class.new(type: :datetime).datetime?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: %w[2024-01-15T10:30:00Z], type: :datetime)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :datetime)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :milestone, type: :datetime)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: %w[2024-01-15T10:30:00Z], type: :datetime)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :datetime).formattable?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :datetime).scalar?).to be(true)
    end
  end
end
