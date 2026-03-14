# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Record do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(default: nil, example: nil, of: nil, type: :record)

      expect(param.default).to be_nil
      expect(param.example).to be_nil
      expect(param.of).to be_nil
    end
  end

  describe '#record?' do
    it 'returns true when record' do
      expect(described_class.new(of: nil, type: :record).record?).to be(true)
    end
  end

  describe '#concrete?' do
    it 'returns true when concrete' do
      expect(described_class.new(of: nil, type: :record).concrete?).to be(true)
    end
  end

  describe '#of' do
    it 'returns the of' do
      param = described_class.new(
        of: { default: nil, deprecated: false, description: nil, example: nil, nullable: false, optional: false, type: :string },
        type: :record,
      )

      expect(param.of).to be_a(Apiwork::Introspection::Param::String)
    end

    it 'returns nil when not set' do
      param = described_class.new(of: nil, type: :record)

      expect(param.of).to be_nil
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
        of: nil,
        optional: false,
        type: :record,
      )

      expect(param.to_h).to include(default: nil, example: nil, of: nil)
    end
  end
end
