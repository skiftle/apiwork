# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Object do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(partial: true, shape: nil, type: :object)

      expect(param.partial?).to be(true)
    end
  end

  describe '#object?' do
    it 'returns true when object' do
      expect(described_class.new(shape: nil, type: :object).object?).to be(true)
    end
  end

  describe '#shape' do
    it 'returns the shape' do
      param = described_class.new(
        shape: { title: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string } },
        type: :object,
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
        nullable: false,
        optional: false,
        partial: false,
        shape: {},
        type: :object,
      )

      expect(param.to_h).to include(partial: false, shape: {})
    end
  end
end
