# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Literal do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(type: :literal, value: 'draft')

      expect(param.value).to eq('draft')
    end
  end

  describe '#literal?' do
    it 'returns true when literal' do
      expect(described_class.new(type: :literal).literal?).to be(true)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      param = described_class.new(
        default: nil,
        deprecated: false,
        description: nil,
        example: nil,
        nullable: false,
        optional: false,
        type: :literal,
        value: 'draft',
      )

      expect(param.to_h).to include(value: 'draft')
    end
  end
end
