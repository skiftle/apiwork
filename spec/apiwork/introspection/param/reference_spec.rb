# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Reference do
  describe '#initialize' do
    it 'creates with required attributes' do
      param = described_class.new(reference: :invoice, type: :reference)

      expect(param.reference).to eq(:invoice)
    end
  end

  describe '#reference?' do
    it 'returns true when reference' do
      expect(described_class.new(type: :reference).reference?).to be(true)
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
        reference: :invoice,
        type: :reference,
      )

      expect(param.to_h).to include(reference: :invoice)
    end
  end
end
