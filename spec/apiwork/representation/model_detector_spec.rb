# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::ModelDetector do
  describe '#detect' do
    it 'returns the model class' do
      detector = described_class.new(Api::V1::InvoiceRepresentation)

      result = detector.detect

      expect(result).to eq(Invoice)
    end

    context 'when abstract' do
      it 'returns nil' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        detector = described_class.new(representation_class)

        result = detector.detect

        expect(result).to be_nil
      end
    end
  end

  describe '#sti_base?' do
    it 'returns true when STI base' do
      detector = described_class.new(Api::V1::CustomerRepresentation)

      expect(detector.sti_base?(Customer)).to be(true)
    end

    it 'returns false when not STI base' do
      detector = described_class.new(Api::V1::InvoiceRepresentation)

      expect(detector.sti_base?(Invoice)).to be(false)
    end
  end
end
