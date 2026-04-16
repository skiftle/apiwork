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
        expect(attribute.write_only?).to be(false)
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
          write_only: true,
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
        expect(attribute.write_only?).to be(true)
      end
    end

    context 'with string column with limit' do
      it 'auto-detects max from column limit' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
        attribute = described_class.new(:reference_code, representation_class)

        expect(attribute.max).to eq(20)
      end

      it 'clamps explicit max to column limit' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
        attribute = described_class.new(:reference_code, representation_class, max: 1000)

        expect(attribute.max).to eq(20)
      end

      it 'preserves explicit max within column limit' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
        attribute = described_class.new(:reference_code, representation_class, max: 10)

        expect(attribute.max).to eq(10)
      end
    end

    context 'with string column without limit' do
      it 'does not set max' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
        attribute = described_class.new(:number, representation_class)

        expect(attribute.max).to be_nil
      end
    end

    context 'with decimal column' do
      it 'auto-detects min and max from precision and scale' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:unit_price, representation_class)

        expect(attribute.min).to eq(-99_999_999.99)
        expect(attribute.max).to eq(99_999_999.99)
      end

      it 'clamps explicit min to column bounds' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:unit_price, representation_class, min: -999_999_999)

        expect(attribute.min).to eq(-99_999_999.99)
      end

      it 'clamps explicit max to column bounds' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:unit_price, representation_class, max: 999_999_999)

        expect(attribute.max).to eq(99_999_999.99)
      end

      it 'preserves explicit bounds within column precision' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:unit_price, representation_class, max: 1000, min: 0)

        expect(attribute.min).to eq(0)
        expect(attribute.max).to eq(1000)
      end
    end

    context 'with integer column' do
      it 'auto-detects min and max from column limit' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:quantity, representation_class)

        expect(attribute.min).to eq(-2_147_483_648)
        expect(attribute.max).to eq(2_147_483_647)
      end

      it 'clamps explicit min to column bounds' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:quantity, representation_class, min: -5_000_000_000)

        expect(attribute.min).to eq(-2_147_483_648)
      end

      it 'clamps explicit max to column bounds' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:quantity, representation_class, max: 5_000_000_000)

        expect(attribute.max).to eq(2_147_483_647)
      end

      it 'preserves explicit bounds within column limits' do
        representation_class = Class.new(Apiwork::Representation::Base) { model Item }
        attribute = described_class.new(:quantity, representation_class, max: 100, min: 0)

        expect(attribute.min).to eq(0)
        expect(attribute.max).to eq(100)
      end
    end
  end

  describe '#decode' do
    context 'with decode proc' do
      it 'returns the transformed value' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        attribute = described_class.new(:number, representation_class, decode: lambda(&:downcase), type: :string)

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

  describe '#default' do
    it 'returns the explicit value' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, default: 'INV-000', type: :string)

      expect(attribute.default).to eq('INV-000')
    end

    it 'returns nil when explicitly set to nil' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, default: nil, type: :string)

      expect(attribute.default).to be_nil
    end

    it 'returns nil when not set and column has no default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
      attribute = described_class.new(:number, representation_class)

      expect(attribute.default).to be_nil
    end

    it 'auto-detects from column with static default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
      attribute = described_class.new(:sent, representation_class)

      expect(attribute.default).to be(false)
    end

    it 'prefers explicit value over column default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
      attribute = described_class.new(:sent, representation_class, default: true)

      expect(attribute.default).to be(true)
    end

    it 'returns empty string when empty is true and no other default' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:notes, representation_class, empty: true, type: :string)

      expect(attribute.default).to eq('')
    end

    it 'returns nil when column is nullable and optional with no other default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Customer }
      attribute = described_class.new(:email, representation_class)

      expect(attribute.default).to be_nil
    end

    it 'does not auto-default when column is nullable but explicitly required' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Customer }
      attribute = described_class.new(:email, representation_class, optional: false)

      expect(attribute.default?).to be(false)
    end
  end

  describe '#default?' do
    it 'returns true when explicitly set to a value' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, default: 'INV-000', type: :string)

      expect(attribute.default?).to be(true)
    end

    it 'returns true when explicitly set to nil' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, default: nil, type: :string)

      expect(attribute.default?).to be(true)
    end

    it 'returns true when auto-detected from column default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
      attribute = described_class.new(:sent, representation_class)

      expect(attribute.default?).to be(true)
    end

    it 'returns false when not set and column has no default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Invoice }
      attribute = described_class.new(:number, representation_class)

      expect(attribute.default?).to be(false)
    end

    it 'returns true when empty is true and no other default' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:notes, representation_class, empty: true, type: :string)

      expect(attribute.default?).to be(true)
    end

    it 'returns true when column is nullable and optional with no other default' do
      representation_class = Class.new(Apiwork::Representation::Base) { model Customer }
      attribute = described_class.new(:email, representation_class)

      expect(attribute.default?).to be(true)
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
        attribute = described_class.new(:number, representation_class, encode: lambda(&:upcase), type: :string)

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

  describe '#write_only?' do
    it 'returns true when write_only' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string, write_only: true)

      expect(attribute.write_only?).to be(true)
    end

    it 'returns false when not write_only' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      attribute = described_class.new(:number, representation_class, type: :string)

      expect(attribute.write_only?).to be(false)
    end
  end
end
