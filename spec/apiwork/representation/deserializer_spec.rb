# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Deserializer do
  describe '#deserialize' do
    it 'returns the deserialized hash' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Invoice
        attribute :number
      end
      deserializer = described_class.new(representation_class)

      result = deserializer.deserialize({ number: 'INV-001' })

      expect(result).to eq({ number: 'INV-001' })
    end

    context 'with array payload' do
      it 'returns the deserialized array' do
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize([{ number: 'INV-001' }, { number: 'INV-002' }])

        expect(result).to eq([{ number: 'INV-001' }, { number: 'INV-002' }])
      end
    end

    context 'with collection association' do
      it 'returns the deserialized hash' do
        item_representation = Class.new(Apiwork::Representation::Base) do
          model Item
          attribute :description
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
          has_many :items, representation: item_representation
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize({ items: [{ description: 'Consulting hours' }], number: 'INV-001' })

        expect(result).to eq({ items: [{ description: 'Consulting hours' }], number: 'INV-001' })
      end
    end

    context 'with singular association' do
      it 'returns the deserialized hash' do
        invoice_representation = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
        end
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Item
          attribute :description
          belongs_to :invoice, representation: invoice_representation
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize({ description: 'Consulting hours', invoice: { number: 'INV-001' } })

        expect(result).to eq({ description: 'Consulting hours', invoice: { number: 'INV-001' } })
      end
    end

    context 'when key is not present in hash' do
      it 'returns an empty hash' do
        representation_class = Class.new(Apiwork::Representation::Base) do
          model Invoice
          attribute :number
        end
        deserializer = described_class.new(representation_class)

        result = deserializer.deserialize({})

        expect(result).to eq({})
      end
    end
  end
end
