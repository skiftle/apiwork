# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Number do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(enum: [0.5, 1.0], max: 100, min: 0, type: :number)

      expect(param.min).to eq(0)
      expect(param.max).to eq(100)
      expect(param.enum).to eq([0.5, 1.0])
    end
  end

  describe '#boundable?' do
    it 'returns true when boundable' do
      expect(described_class.new(type: :number).boundable?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: [0.5, 1.0], type: :number)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :number)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :rate, type: :number)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: [0.5, 1.0], type: :number)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :number).formattable?).to be(false)
    end
  end

  describe '#number?' do
    it 'returns true when number' do
      expect(described_class.new(type: :number).number?).to be(true)
    end
  end

  describe '#numeric?' do
    it 'returns true when numeric' do
      expect(described_class.new(type: :number).numeric?).to be(true)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :number).scalar?).to be(true)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      param = described_class.new(
        default: nil,
        deprecated: false,
        description: nil,
        example: nil,
        max: 100,
        min: 0,
        nullable: false,
        optional: false,
        type: :number,
      )

      expect(param.to_h).to include(max: 100, min: 0)
    end
  end
end
