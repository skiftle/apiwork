# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::ModelDetector do
  describe '#detect' do
    context 'when abstract' do
      it 'returns nil' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        detector = described_class.new(representation_class)

        expect(detector.detect).to be_nil
      end
    end

    context 'without name' do
      it 'returns nil' do
        representation_class = double(:representation_class, abstract?: false, name: nil)
        detector = described_class.new(representation_class)

        expect(detector.detect).to be_nil
      end
    end

    context 'with matching model' do
      it 'returns the model class' do
        representation_class = double(:representation_class, abstract?: false, name: 'PostRepresentation')
        detector = described_class.new(representation_class)

        expect(detector.detect).to eq(Post)
      end
    end

    context 'with namespaced matching model' do
      it 'tries namespaced constant first' do
        representation_class = double(:representation_class, abstract?: false, name: 'SomeNamespace::PostRepresentation')
        detector = described_class.new(representation_class)

        expect(detector.detect).to eq(Post)
      end
    end

    context 'without matching model' do
      it 'raises ConfigurationError' do
        representation_class = double(:representation_class, abstract?: false, name: 'ZzNonExistentRepresentation')
        detector = described_class.new(representation_class)

        expect { detector.detect }.to raise_error(Apiwork::ConfigurationError, /Could not find model 'ZzNonExistent'/)
      end
    end

    context 'when detected constant is not an ActiveRecord model' do
      it 'raises ConfigurationError' do
        representation_class = double(:representation_class, abstract?: false, name: 'StringRepresentation')
        detector = described_class.new(representation_class)

        expect { detector.detect }.to raise_error(Apiwork::ConfigurationError, /Could not find model 'String'/)
      end
    end

    context 'when name equals Representation' do
      it 'returns nil' do
        representation_class = double(:representation_class, abstract?: false, name: 'Representation')
        detector = described_class.new(representation_class)

        expect(detector.detect).to be_nil
      end
    end
  end

  describe '#sti_base?' do
    it 'returns true for STI base model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_base?(Client)).to be true
    end

    it 'returns false for STI subclass model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_base?(PersonClient)).to be false
    end

    it 'returns false for non-STI model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_base?(Post)).to be false
    end

    it 'returns false for abstract model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_base?(ApplicationRecord)).to be false
    end
  end

  describe '#sti_subclass?' do
    it 'returns true for STI subclass model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_subclass?(PersonClient)).to be true
    end

    it 'returns false for STI base model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_subclass?(Client)).to be false
    end

    it 'returns false for non-STI model' do
      detector = described_class.new(double(:representation_class))

      expect(detector.sti_subclass?(Post)).to be false
    end
  end

  describe '#superclass_is_sti_base?' do
    it 'returns true when superclass model is the STI base' do
      superclass = double(:superclass, model_class: Client)
      representation_class = double(:representation_class, superclass:)
      detector = described_class.new(representation_class)

      expect(detector.superclass_is_sti_base?(PersonClient)).to be true
    end

    it 'returns false when superclass model is nil' do
      superclass = double(:superclass, model_class: nil)
      representation_class = double(:representation_class, superclass:)
      detector = described_class.new(representation_class)

      expect(detector.superclass_is_sti_base?(PersonClient)).to be false
    end

    it 'returns false when superclass model does not match base class' do
      superclass = double(:superclass, model_class: Post)
      representation_class = double(:representation_class, superclass:)
      detector = described_class.new(representation_class)

      expect(detector.superclass_is_sti_base?(PersonClient)).to be false
    end
  end
end
