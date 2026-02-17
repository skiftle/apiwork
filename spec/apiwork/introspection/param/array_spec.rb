# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Array do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(max: 100, min: 1, of: nil, shape: nil, type: :array)

      expect(param.min).to eq(1)
      expect(param.max).to eq(100)
      expect(param.of).to be_nil
      expect(param.shape).to eq({})
    end
  end

  describe '#array?' do
    it 'returns true when array' do
      expect(described_class.new(of: nil, shape: nil, type: :array).array?).to be(true)
    end
  end

  describe '#boundable?' do
    it 'returns true when boundable' do
      expect(described_class.new(of: nil, shape: nil, type: :array).boundable?).to be(true)
    end
  end

  describe '#of' do
    it 'returns the of' do
      param = described_class.new(
        of: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string },
        shape: nil,
        type: :array,
      )

      expect(param.of).to be_a(Apiwork::Introspection::Param::String)
    end

    it 'returns nil when not set' do
      param = described_class.new(of: nil, shape: nil, type: :array)

      expect(param.of).to be_nil
    end
  end

  describe '#shape' do
    it 'returns the shape' do
      param = described_class.new(
        of: nil,
        shape: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        type: :array,
      )

      expect(param.shape[:title]).to be_a(Apiwork::Introspection::Param::String)
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
        min: 1,
        nullable: false,
        of: nil,
        optional: false,
        shape: {},
        type: :array,
      )

      expect(param.to_h).to include(max: 100, min: 1, of: nil, shape: {})
    end
  end
end
