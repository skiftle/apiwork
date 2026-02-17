# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Type do
  describe '#deprecated?' do
    it 'returns true when deprecated' do
      type = described_class.new(
        deprecated: true,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.deprecated?).to be(false)
    end
  end

  describe '#extends?' do
    it 'returns true when extends' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [:invoice],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.extends?).to be(true)
    end

    it 'returns false when not extends' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.extends?).to be(false)
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      type = described_class.new(
        deprecated: false,
        description: 'Ruby developer',
        discriminator: :type,
        example: { amount: 42 },
        extends: [:invoice],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.type).to eq(:object)
      expect(type.description).to eq('Ruby developer')
      expect(type.discriminator).to eq(:type)
      expect(type.example).to eq({ amount: 42 })
      expect(type.extends).to eq([:invoice])
    end
  end

  describe '#object?' do
    it 'returns true when object' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.object?).to be(true)
    end

    it 'returns false when not object' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :union,
        variants: [],
      )

      expect(type.object?).to be(false)
    end
  end

  describe '#shape' do
    it 'returns the shape' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        type: :object,
        variants: [],
      )

      expect(type.shape[:title]).to be_a(Apiwork::Introspection::Param::String)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.to_h).to eq(
        {
          deprecated: false,
          description: nil,
          discriminator: nil,
          example: nil,
          extends: [],
          shape: {},
          type: :object,
          variants: [],
        },
      )
    end
  end

  describe '#union?' do
    it 'returns true when union' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :union,
        variants: [],
      )

      expect(type.union?).to be(true)
    end

    it 'returns false when not union' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: nil,
        example: nil,
        extends: [],
        shape: {},
        type: :object,
        variants: [],
      )

      expect(type.union?).to be(false)
    end
  end

  describe '#variants' do
    it 'returns the variants' do
      type = described_class.new(
        deprecated: false,
        description: nil,
        discriminator: :type,
        example: nil,
        extends: [],
        shape: {},
        type: :union,
        variants: [
          { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string },
        ],
      )

      expect(type.variants.first).to be_a(Apiwork::Introspection::Param::String)
    end
  end
end
