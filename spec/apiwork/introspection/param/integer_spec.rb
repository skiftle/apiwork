# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Integer do
  describe '#boundable?' do
    it 'returns true when boundable' do
      expect(described_class.new(type: :integer).boundable?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: [1, 2, 3], type: :integer)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :integer)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :priority, type: :integer)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: [1, 2, 3], type: :integer)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns true when formattable' do
      expect(described_class.new(type: :integer).formattable?).to be(true)
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(
        enum: [1, 2, 3],
        format: :int32,
        max: 100,
        min: 0,
        type: :integer,
      )

      expect(param.format).to eq(:int32)
      expect(param.min).to eq(0)
      expect(param.max).to eq(100)
      expect(param.enum).to eq([1, 2, 3])
    end
  end

  describe '#integer?' do
    it 'returns true when integer' do
      expect(described_class.new(type: :integer).integer?).to be(true)
    end
  end

  describe '#numeric?' do
    it 'returns true when numeric' do
      expect(described_class.new(type: :integer).numeric?).to be(true)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :integer).scalar?).to be(true)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      param = described_class.new(
        default: nil,
        deprecated: false,
        description: nil,
        example: nil,
        format: :int32,
        max: 100,
        min: 0,
        nullable: false,
        optional: false,
        type: :integer,
      )

      expect(param.to_h).to include(format: :int32, max: 100, min: 0)
    end
  end
end
