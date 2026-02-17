# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Union do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(discriminator: :type, type: :union, variants: [])

      expect(param.discriminator).to eq(:type)
      expect(param.variants).to eq([])
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      param = described_class.new(
        default: nil,
        deprecated: false,
        description: nil,
        discriminator: :type,
        example: nil,
        nullable: false,
        optional: false,
        type: :union,
        variants: [],
      )

      expect(param.to_h).to include(discriminator: :type, variants: [])
    end
  end

  describe '#union?' do
    it 'returns true when union' do
      expect(described_class.new(type: :union, variants: []).union?).to be(true)
    end
  end

  describe '#variants' do
    it 'returns the variants' do
      param = described_class.new(
        type: :union,
        variants: [
          { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string },
        ],
      )

      expect(param.variants.first).to be_a(Apiwork::Introspection::Param::String)
    end
  end
end
