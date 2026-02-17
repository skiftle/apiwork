# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Boolean do
  describe '#boolean?' do
    it 'returns true when boolean' do
      expect(described_class.new(type: :boolean).boolean?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: [true], type: :boolean)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :boolean)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :active, type: :boolean)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: [true], type: :boolean)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :boolean).formattable?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :boolean).scalar?).to be(true)
    end
  end
end
