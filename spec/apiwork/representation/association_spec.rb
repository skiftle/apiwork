# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Association do
  describe '#initialize' do
    context 'with defaults' do
      it 'creates with required attributes' do
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        association = described_class.new(:comments, :has_many, representation_class)

        expect(association.name).to eq(:comments)
        expect(association.type).to eq(:has_many)
        expect(association.deprecated?).to be(false)
        expect(association.description).to be_nil
        expect(association.example).to be_nil
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.polymorphic).to be_nil
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(Apiwork::Representation::Base) { abstract! }
        representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
        association = described_class.new(
          :comments,
          :has_many,
          representation_class,
          deprecated: true,
          description: 'The comments',
          example: { id: 1 },
          filterable: true,
          include: :always,
          nullable: true,
          representation: target_representation,
          sortable: true,
          writable: true,
        )

        expect(association.name).to eq(:comments)
        expect(association.type).to eq(:has_many)
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The comments')
        expect(association.example).to eq({ id: 1 })
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '#collection?' do
    it 'returns true when a collection' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.collection?).to be(true)
    end

    it 'returns false when not a collection' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:author, :belongs_to, representation_class)

      expect(association.collection?).to be(false)
    end
  end

  describe '#deprecated?' do
    it 'returns true when deprecated' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, deprecated: true)

      expect(association.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.deprecated?).to be(false)
    end
  end

  describe '#filterable?' do
    it 'returns true when filterable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, filterable: true)

      expect(association.filterable?).to be(true)
    end

    it 'returns false when not filterable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.filterable?).to be(false)
    end
  end

  describe '#nullable?' do
    it 'returns true when nullable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, nullable: true)

      expect(association.nullable?).to be(true)
    end

    it 'returns false when not nullable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, nullable: false)

      expect(association.nullable?).to be(false)
    end
  end

  describe '#polymorphic?' do
    it 'returns true when polymorphic' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      polymorphic_representation = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(
        :commentable,
        :belongs_to,
        representation_class,
        polymorphic: [polymorphic_representation],
      )

      expect(association.polymorphic?).to be(true)
    end

    it 'returns false when not polymorphic' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.polymorphic?).to be(false)
    end
  end

  describe '#representation_class' do
    it 'returns the representation class' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      target_representation = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(
        :comments,
        :has_many,
        representation_class,
        representation: target_representation,
      )

      expect(association.representation_class).to eq(target_representation)
    end

    it 'returns nil when not set' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.representation_class).to be_nil
    end
  end

  describe '#singular?' do
    it 'returns true when singular' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:author, :belongs_to, representation_class)

      expect(association.singular?).to be(true)
    end

    it 'returns false when not singular' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.singular?).to be(false)
    end
  end

  describe '#sortable?' do
    it 'returns true when sortable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, sortable: true)

      expect(association.sortable?).to be(true)
    end

    it 'returns false when not sortable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.sortable?).to be(false)
    end
  end

  describe '#writable?' do
    it 'returns true when writable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, writable: true)

      expect(association.writable?).to be(true)
    end

    it 'returns false when not writable' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class)

      expect(association.writable?).to be(false)
    end
  end

  describe '#writable_for?' do
    it 'returns true when writable for the action' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, writable: :create)

      expect(association.writable_for?(:create)).to be(true)
    end

    it 'returns false when not writable for the action' do
      representation_class = Class.new(Apiwork::Representation::Base) { abstract! }
      association = described_class.new(:comments, :has_many, representation_class, writable: :create)

      expect(association.writable_for?(:update)).to be(false)
    end
  end
end
