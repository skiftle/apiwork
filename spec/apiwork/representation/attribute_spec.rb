# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Attribute do
  describe '#initialize' do
    context 'with defaults' do
      it 'creates with required attributes' do
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
        end
        attribute = described_class.new(:number, representation_class)

        expect(attribute.name).to eq(:number)
        expect(attribute.type).to eq(:string)
        expect(attribute.deprecated?).to be(false)
        expect(attribute.description).to be_nil
        expect(attribute.enum).to be_nil
        expect(attribute.example).to be_nil
        expect(attribute.filterable?).to be(false)
        expect(attribute.format).to be_nil
        expect(attribute.max).to be_nil
        expect(attribute.min).to be_nil
        expect(attribute.nullable?).to be(false)
        expect(attribute.of).to be_nil
        expect(attribute.optional?).to be(false)
        expect(attribute.preload).to be_nil
        expect(attribute.sortable?).to be(false)
        expect(attribute.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(
          :number,
          representation_class,
          deprecated: true,
          description: 'The number',
          enum: %w[draft published],
          example: 'INV-001',
          filterable: true,
          format: :email,
          max: 100,
          min: 1,
          nullable: true,
          optional: true,
          preload: :items,
          sortable: true,
          type: :string,
          writable: true,
        )

        expect(attribute.name).to eq(:number)
        expect(attribute.type).to eq(:string)
        expect(attribute.deprecated?).to be(true)
        expect(attribute.description).to eq('The number')
        expect(attribute.enum).to eq(%w[draft published])
        expect(attribute.example).to eq('INV-001')
        expect(attribute.filterable?).to be(true)
        expect(attribute.format).to eq(:email)
        expect(attribute.max).to eq(100)
        expect(attribute.min).to eq(1)
        expect(attribute.nullable?).to be(true)
        expect(attribute.optional?).to be(true)
        expect(attribute.preload).to eq(:items)
        expect(attribute.sortable?).to be(true)
        expect(attribute.writable?).to be(true)
      end
    end
  end

  describe '#decode' do
    context 'with decode proc' do
      it 'returns the transformed value' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, decode: ->(value) { value.downcase }, type: :string)

        expect(attribute.decode('INV-001')).to eq('inv-001')
      end
    end

    context 'when empty' do
      it 'returns nil for blank value' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, empty: true, type: :string)

        expect(attribute.decode('')).to be_nil
      end
    end

    context 'without decode proc' do
      it 'returns the value' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, type: :string)

        expect(attribute.decode('INV-001')).to eq('INV-001')
      end
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, deprecated: true, type: :string)

      expect(attribute.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string)

      expect(attribute.deprecated?).to be(false)
    end
  end

  describe '#encode' do
    context 'when empty and value is nil' do
      it 'returns empty string' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, empty: true, type: :string)

        expect(attribute.encode(nil)).to eq('')
      end
    end

    context 'with encode proc' do
      it 'returns the transformed value' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, encode: ->(value) { value.upcase }, type: :string)

        expect(attribute.encode('inv-001')).to eq('INV-001')
      end
    end

    context 'without encode proc' do
      it 'returns the value' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, type: :string)

        expect(attribute.encode('INV-001')).to eq('INV-001')
      end
    end
  end

  describe '#filterable?' do
    it 'returns true when filterable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, filterable: true, type: :string)

      expect(attribute.filterable?).to be(true)
    end

    it 'returns false when not filterable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string)

      expect(attribute.filterable?).to be(false)
    end
  end

  describe '#nullable?' do
    it 'returns true when nullable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, nullable: true, type: :string)

      expect(attribute.nullable?).to be(true)
    end

    it 'returns false when not nullable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, nullable: false, type: :string)

      expect(attribute.nullable?).to be(false)
    end

    it 'returns false when empty' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, empty: true, nullable: true, type: :string)

      expect(attribute.nullable?).to be(false)
    end
  end

  describe '#optional?' do
    it 'returns true when optional' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, optional: true, type: :string)

      expect(attribute.optional?).to be(true)
    end

    it 'returns false when not optional' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, optional: false, type: :string)

      expect(attribute.optional?).to be(false)
    end
  end

  describe '#sortable?' do
    it 'returns true when sortable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, sortable: true, type: :string)

      expect(attribute.sortable?).to be(true)
    end

    it 'returns false when not sortable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string)

      expect(attribute.sortable?).to be(false)
    end
  end

  describe '#writable?' do
    it 'returns true when writable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string, writable: true)

      expect(attribute.writable?).to be(true)
    end

    it 'returns false when not writable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string)

      expect(attribute.writable?).to be(false)
    end
  end

  describe '#writable_for?' do
    it 'returns true when writable for the action' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string, writable: :create)

      expect(attribute.writable_for?(:create)).to be(true)
    end

    it 'returns false when not writable for the action' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string, writable: :create)

      expect(attribute.writable_for?(:update)).to be(false)
    end
  end
end
