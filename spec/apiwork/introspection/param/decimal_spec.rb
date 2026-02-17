# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Decimal do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(enum: [9.99, 19.99], max: 100, min: 0, type: :decimal)

      expect(param.min).to eq(0)
      expect(param.max).to eq(100)
      expect(param.enum).to eq([9.99, 19.99])
    end
  end

  describe '#boundable?' do
    it 'returns true when boundable' do
      expect(described_class.new(type: :decimal).boundable?).to be(true)
    end
  end

  describe '#decimal?' do
    it 'returns true when decimal' do
      expect(described_class.new(type: :decimal).decimal?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: [9.99, 19.99], type: :decimal)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :decimal)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :price, type: :decimal)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: [9.99, 19.99], type: :decimal)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :decimal).formattable?).to be(false)
    end
  end

  describe '#numeric?' do
    it 'returns true when numeric' do
      expect(described_class.new(type: :decimal).numeric?).to be(true)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :decimal).scalar?).to be(true)
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
        type: :decimal,
      )

      expect(param.to_h).to include(max: 100, min: 0)
    end
  end
end
