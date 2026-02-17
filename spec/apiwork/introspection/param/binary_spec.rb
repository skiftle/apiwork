# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Binary do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(enum: %w[SGVsbG8=], type: :binary)

      expect(param.enum).to eq(%w[SGVsbG8=])
    end
  end

  describe '#binary?' do
    it 'returns true when binary' do
      expect(described_class.new(type: :binary).binary?).to be(true)
    end
  end

  describe '#enum?' do
    it 'returns true when enum' do
      param = described_class.new(enum: %w[SGVsbG8=], type: :binary)

      expect(param.enum?).to be(true)
    end

    it 'returns false when not enum' do
      param = described_class.new(type: :binary)

      expect(param.enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns true when enum reference' do
      param = described_class.new(enum: :payload, type: :binary)

      expect(param.enum_reference?).to be(true)
    end

    it 'returns false when not enum reference' do
      param = described_class.new(enum: %w[SGVsbG8=], type: :binary)

      expect(param.enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :binary).formattable?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns true when scalar' do
      expect(described_class.new(type: :binary).scalar?).to be(true)
    end
  end
end
