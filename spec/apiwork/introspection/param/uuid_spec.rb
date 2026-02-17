# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::UUID do
  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: %w[550e8400-e29b-41d4-a716-446655440000], type: :uuid)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :uuid)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :identifier, type: :uuid)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: %w[550e8400-e29b-41d4-a716-446655440000], type: :uuid)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :uuid).formattable?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :uuid).scalar?).to be(true)
    end
  end

  describe '#uuid?' do
    it 'returns true when uuid' do
      expect(described_class.new(type: :uuid).uuid?).to be(true)
    end
  end
end
