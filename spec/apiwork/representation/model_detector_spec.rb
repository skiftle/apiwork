# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::ModelDetector do
  describe '#detect' do
    it 'returns the model class' do
      detector = described_class.new(Api::V1::PostRepresentation)

      result = detector.detect

      expect(result).to eq(Post)
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
      detector = described_class.new(Api::V1::ClientRepresentation)

      expect(detector.sti_base?(Client)).to be(true)
    end

    it 'returns false when not STI base' do
      detector = described_class.new(Api::V1::PostRepresentation)

      expect(detector.sti_base?(Post)).to be(false)
    end
  end

  describe '#sti_subclass?' do
    it 'returns true when STI subclass' do
      detector = described_class.new(Api::V1::PersonClientRepresentation)

      expect(detector.sti_subclass?(PersonClient)).to be(true)
    end

    it 'returns false when not STI subclass' do
      detector = described_class.new(Api::V1::ClientRepresentation)

      expect(detector.sti_subclass?(Client)).to be(false)
    end
  end

  describe '#superclass_is_sti_base?' do
    it 'returns true when superclass is STI base' do
      detector = described_class.new(Api::V1::PersonClientRepresentation)

      expect(detector.superclass_is_sti_base?(PersonClient)).to be(true)
    end

    it 'returns false when superclass is not STI base' do
      base_representation = Class.new(Apiwork::Representation::Base) { abstract! }
      child_representation = Class.new(base_representation) { model Post }
      detector = described_class.new(child_representation)

      expect(detector.superclass_is_sti_base?(Post)).to be(false)
    end
  end
end
