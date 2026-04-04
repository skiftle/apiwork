# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Serializer do
  describe '#serialize' do
    it 'returns the serialized hash' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Invoice
        attribute :number
      end
      invoice = Invoice.new(number: 'INV-001')
      representation = representation_class.new(invoice)
      serializer = described_class.new(representation, nil)

      result = serializer.serialize

      expect(result).to eq({ number: 'INV-001' })
    end

    context 'with always-included association' do
      it 'returns the serialized hash' do
        item_representation = Class.new(Apiwork::Representation::Base) do
          model Item
          attribute :description
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
          has_many :items, include: :always, representation: item_representation
        end
        invoice = Invoice.new(number: 'INV-001')
        representation = representation_class.new(invoice)
        serializer = described_class.new(representation, nil)

        result = serializer.serialize

        expect(result).to eq({ items: [], number: 'INV-001' })
      end
    end

    context 'with optional association' do
      it 'returns the serialized hash' do
        item_representation = Class.new(Apiwork::Representation::Base) do
          model Item
          attribute :description
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
          has_many :items, representation: item_representation
        end
        invoice = Invoice.new(number: 'INV-001')
        representation = representation_class.new(invoice)
        serializer = described_class.new(representation, nil)

        result = serializer.serialize

        expect(result).to eq({ number: 'INV-001' })
      end
    end

    context 'with write_only attribute' do
      it 'excludes the attribute' do
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
          attribute :notes, write_only: true
        end
        invoice = Invoice.new(notes: 'Rush delivery', number: 'INV-001')
        representation = representation_class.new(invoice)
        serializer = described_class.new(representation, nil)

        result = serializer.serialize

        expect(result).to eq({ number: 'INV-001' })
      end
    end

    context 'with explicit includes' do
      it 'returns the serialized hash' do
        item_representation = Class.new(Apiwork::Representation::Base) do
          model Item
          attribute :description
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
          has_many :items, representation: item_representation
        end
        invoice = Invoice.new(number: 'INV-001')
        representation = representation_class.new(invoice)
        serializer = described_class.new(representation, [:items])

        result = serializer.serialize

        expect(result).to eq({ items: [], number: 'INV-001' })
      end
    end
  end
end
