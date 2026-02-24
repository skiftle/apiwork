# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::String do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(
        enum: %w[draft published],
        format: :email,
        max: 100,
        min: 1,
        type: :string,
      )

      expect(param.format).to eq(:email)
      expect(param.min).to eq(1)
      expect(param.max).to eq(100)
      expect(param.enum).to eq(%w[draft published])
    end
  end

  describe '#boundable?' do
    it 'returns true when boundable' do
      expect(described_class.new(type: :string).boundable?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: %w[draft published], type: :string)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :string)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :status, type: :string)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: %w[draft published], type: :string)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns true when formattable' do
      expect(described_class.new(type: :string).formattable?).to be(true)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :string).scalar?).to be(true)
    end
  end

  describe '#string?' do
    it 'returns true when string' do
      expect(described_class.new(type: :string).string?).to be(true)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      param = described_class.new(
        default: nil,
        deprecated: false,
        description: nil,
        example: nil,
        format: :email,
        max: 100,
        min: 1,
        nullable: false,
        optional: false,
        type: :string,
      )

      expect(param.to_h).to include(format: :email, max: 100, min: 1)
    end
  end
end
