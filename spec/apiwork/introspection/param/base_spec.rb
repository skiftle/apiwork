# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Base do
  describe '#array?' do
    it 'returns false when not array' do
      expect(described_class.new(type: :string).array?).to be(false)
    end
  end

  describe '#binary?' do
    it 'returns false when not binary' do
      expect(described_class.new(type: :string).binary?).to be(false)
    end
  end

  describe '#boolean?' do
    it 'returns false when not boolean' do
      expect(described_class.new(type: :string).boolean?).to be(false)
    end
  end

  describe '#boundable?' do
    it 'returns false when not boundable' do
      expect(described_class.new(type: :string).boundable?).to be(false)
    end
  end

  describe '#date?' do
    it 'returns false when not date' do
      expect(described_class.new(type: :string).date?).to be(false)
    end
  end

  describe '#datetime?' do
    it 'returns false when not datetime' do
      expect(described_class.new(type: :string).datetime?).to be(false)
    end
  end

  describe '#decimal?' do
    it 'returns false when not decimal' do
      expect(described_class.new(type: :string).decimal?).to be(false)
    end
  end

  describe '#default?' do
    it 'returns true when default' do
      param = described_class.new(default: 'Untitled', type: :string)

      expect(param.default?).to be(true)
    end

    it 'returns false when not default' do
      param = described_class.new(type: :string)

      expect(param.default?).to be(false)
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      param = described_class.new(deprecated: true, type: :string)

      expect(param.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      param = described_class.new(deprecated: false, type: :string)

      expect(param.deprecated?).to be(false)
    end
  end

  describe '#enum?' do
    it 'returns false when not enum' do
      expect(described_class.new(type: :string).enum?).to be(false)
    end
  end

  describe '#enum_reference?' do
    it 'returns false when not enum reference' do
      expect(described_class.new(type: :string).enum_reference?).to be(false)
    end
  end

  describe '#formattable?' do
    it 'returns false when not formattable' do
      expect(described_class.new(type: :string).formattable?).to be(false)
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(
        default: 'Untitled',
        description: 'The title',
        example: 'First Post',
        tag: 'field',
        type: :string,
      )

      expect(param.type).to eq(:string)
      expect(param.description).to eq('The title')
      expect(param.example).to eq('First Post')
      expect(param.default).to eq('Untitled')
      expect(param.tag).to eq('field')
    end
  end

  describe '#integer?' do
    it 'returns false when not integer' do
      expect(described_class.new(type: :string).integer?).to be(false)
    end
  end

  describe '#literal?' do
    it 'returns false when not literal' do
      expect(described_class.new(type: :string).literal?).to be(false)
    end
  end

  describe '#nullable?' do
    it 'returns true when nullable' do
      param = described_class.new(nullable: true, type: :string)

      expect(param.nullable?).to be(true)
    end

    it 'returns false when not nullable' do
      param = described_class.new(nullable: false, type: :string)

      expect(param.nullable?).to be(false)
    end
  end

  describe '#number?' do
    it 'returns false when not number' do
      expect(described_class.new(type: :string).number?).to be(false)
    end
  end

  describe '#numeric?' do
    it 'returns false when not numeric' do
      expect(described_class.new(type: :string).numeric?).to be(false)
    end
  end

  describe '#object?' do
    it 'returns false when not object' do
      expect(described_class.new(type: :string).object?).to be(false)
    end
  end

  describe '#optional?' do
    it 'returns true when optional' do
      param = described_class.new(optional: true, type: :string)

      expect(param.optional?).to be(true)
    end

    it 'returns false when not optional' do
      param = described_class.new(optional: false, type: :string)

      expect(param.optional?).to be(false)
    end
  end

  describe '#partial?' do
    it 'returns false when not partial' do
      expect(described_class.new(type: :string).partial?).to be(false)
    end
  end

  describe '#reference?' do
    it 'returns false when not reference' do
      expect(described_class.new(type: :string).reference?).to be(false)
    end
  end

  describe '#scalar?' do
    it 'returns false when not scalar' do
      expect(described_class.new(type: :string).scalar?).to be(false)
    end
  end

  describe '#string?' do
    it 'returns false when not string' do
      expect(described_class.new(type: :string).string?).to be(false)
    end
  end

  describe '#time?' do
    it 'returns false when not time' do
      expect(described_class.new(type: :string).time?).to be(false)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      param = described_class.new(
        default: 'Untitled',
        deprecated: false,
        description: 'The title',
        example: 'First Post',
        nullable: false,
        optional: false,
        type: :string,
      )

      expect(param.to_h).to eq(
        {
          default: 'Untitled',
          deprecated: false,
          description: 'The title',
          example: 'First Post',
          nullable: false,
          optional: false,
          type: :string,
        },
      )
    end
  end

  describe '#union?' do
    it 'returns false when not union' do
      expect(described_class.new(type: :string).union?).to be(false)
    end
  end

  describe '#unknown?' do
    it 'returns false when not unknown' do
      expect(described_class.new(type: :string).unknown?).to be(false)
    end
  end

  describe '#uuid?' do
    it 'returns false when not uuid' do
      expect(described_class.new(type: :string).uuid?).to be(false)
    end
  end
end
