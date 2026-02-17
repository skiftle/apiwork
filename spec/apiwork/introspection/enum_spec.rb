# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Enum do
  describe '#initialize' do
    it 'creates with required attributes' do
      enum = described_class.new(
        deprecated: false,
        description: 'Ruby developer',
        example: 'draft',
        values: %w[draft published],
      )

      expect(enum.values).to eq(%w[draft published])
      expect(enum.description).to eq('Ruby developer')
      expect(enum.example).to eq('draft')
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      enum = described_class.new(deprecated: true, description: nil, example: nil, values: [])

      expect(enum.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      enum = described_class.new(deprecated: false, description: nil, example: nil, values: [])

      expect(enum.deprecated?).to be(false)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      enum = described_class.new(
        deprecated: false,
        description: 'Ruby developer',
        example: 'draft',
        values: %w[draft published],
      )

      expect(enum.to_h).to eq(
        {
          deprecated: false,
          description: 'Ruby developer',
          example: 'draft',
          values: %w[draft published],
        },
      )
    end
  end
end
