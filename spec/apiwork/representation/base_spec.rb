# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Base do
  describe '.abstract!' do
    it 'marks the class as abstract' do
      representation_class = Class.new(described_class)
      representation_class.abstract!

      expect(representation_class.abstract?).to be(true)
    end
  end

  describe '.abstract?' do
    it 'returns true when abstract' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.abstract?).to be(true)
    end

    it 'returns false when not abstract' do
      representation_class = Class.new(described_class)

      expect(representation_class.abstract?).to be(false)
    end
  end

  describe '.attribute' do
    context 'with defaults' do
      it 'registers the attribute' do
        representation_class = Class.new(described_class) do
          model Invoice
          attribute :number
        end

        expect(representation_class.attributes[:number]).to be_a(Apiwork::Representation::Attribute)
        expect(representation_class.attributes[:number].name).to eq(:number)
        expect(representation_class.attributes[:number].type).to eq(:string)
        expect(representation_class.attributes[:number].deprecated?).to be(false)
        expect(representation_class.attributes[:number].filterable?).to be(false)
        expect(representation_class.attributes[:number].sortable?).to be(false)
        expect(representation_class.attributes[:number].writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        representation_class = Class.new(described_class) do
          model Invoice
          attribute :number,
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
                    writable: true
        end

        attribute = representation_class.attributes[:number]
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
        expect(attribute.type).to eq(:string)
        expect(attribute.writable?).to be(true)
      end
    end
  end

  describe '.belongs_to' do
    context 'with defaults' do
      it 'registers the association' do
        representation_class = Class.new(described_class) do
          abstract!
          belongs_to :customer
        end

        association = representation_class.associations[:customer]
        expect(association).to be_a(Apiwork::Representation::Association)
        expect(association.name).to eq(:customer)
        expect(association.type).to eq(:belongs_to)
        expect(association.deprecated?).to be(false)
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.nullable?).to be(false)
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(described_class) { abstract! }
        representation_class = Class.new(described_class) do
          abstract!
          belongs_to :customer,
                     deprecated: true,
                     description: 'The customer',
                     example: { id: 1 },
                     filterable: true,
                     include: :always,
                     nullable: true,
                     representation: target_representation,
                     sortable: true,
                     writable: true
        end

        association = representation_class.associations[:customer]
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The customer')
        expect(association.example).to eq({ id: 1 })
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.nullable?).to be(true)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '.deprecated!' do
    it 'marks the representation as deprecated' do
      representation_class = Class.new(described_class) do
        abstract!
        deprecated!
      end

      expect(representation_class.deprecated?).to be(true)
    end
  end

  describe '.deprecated?' do
    it 'returns true when deprecated' do
      representation_class = Class.new(described_class) do
        abstract!
        deprecated!
      end

      expect(representation_class.deprecated?).to be(true)
    end

    it 'returns false when not deprecated' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.deprecated?).to be(false)
    end
  end

  describe '.deserialize' do
    it 'returns the deserialized hash' do
      representation_class = Class.new(described_class) do
        model Invoice
        attribute :number, writable: true
      end

      result = representation_class.deserialize({ number: 'INV-001' })

      expect(result).to include(number: 'INV-001')
    end
  end

  describe '.description' do
    it 'returns the description' do
      representation_class = Class.new(described_class) do
        abstract!
        description 'A customer invoice'
      end

      expect(representation_class.description).to eq('A customer invoice')
    end

    it 'returns nil when not set' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.description).to be_nil
    end
  end

  describe '.example' do
    it 'returns the example' do
      representation_class = Class.new(described_class) do
        abstract!
        example id: 1, number: 'INV-001'
      end

      expect(representation_class.example).to eq({ id: 1, number: 'INV-001' })
    end

    it 'returns nil when not set' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.example).to be_nil
    end
  end

  describe '.has_many' do
    context 'with defaults' do
      it 'registers the association' do
        representation_class = Class.new(described_class) do
          abstract!
          has_many :items
        end

        association = representation_class.associations[:items]
        expect(association).to be_a(Apiwork::Representation::Association)
        expect(association.name).to eq(:items)
        expect(association.type).to eq(:has_many)
        expect(association.deprecated?).to be(false)
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.nullable?).to be(false)
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(described_class) { abstract! }
        representation_class = Class.new(described_class) do
          abstract!
          has_many :items,
                   deprecated: true,
                   description: 'The items',
                   example: [{ id: 1 }],
                   filterable: true,
                   include: :always,
                   representation: target_representation,
                   sortable: true,
                   writable: true
        end

        association = representation_class.associations[:items]
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The items')
        expect(association.example).to eq([{ id: 1 }])
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '.has_one' do
    context 'with defaults' do
      it 'registers the association' do
        representation_class = Class.new(described_class) do
          abstract!
          has_one :address
        end

        association = representation_class.associations[:address]
        expect(association).to be_a(Apiwork::Representation::Association)
        expect(association.name).to eq(:address)
        expect(association.type).to eq(:has_one)
        expect(association.deprecated?).to be(false)
        expect(association.filterable?).to be(false)
        expect(association.include).to eq(:optional)
        expect(association.nullable?).to be(false)
        expect(association.sortable?).to be(false)
        expect(association.writable?).to be(false)
      end
    end

    context 'with overrides' do
      it 'forwards all options' do
        target_representation = Class.new(described_class) { abstract! }
        representation_class = Class.new(described_class) do
          abstract!
          has_one :address,
                  deprecated: true,
                  description: 'The address',
                  example: { id: 1 },
                  filterable: true,
                  include: :always,
                  nullable: true,
                  representation: target_representation,
                  sortable: true,
                  writable: true
        end

        association = representation_class.associations[:address]
        expect(association.deprecated?).to be(true)
        expect(association.description).to eq('The address')
        expect(association.example).to eq({ id: 1 })
        expect(association.filterable?).to be(true)
        expect(association.include).to eq(:always)
        expect(association.nullable?).to be(true)
        expect(association.representation_class).to eq(target_representation)
        expect(association.sortable?).to be(true)
        expect(association.writable?).to be(true)
      end
    end
  end

  describe '.model' do
    it 'sets the model class' do
      representation_class = Class.new(described_class) do
        model Invoice
      end

      expect(representation_class.model_class).to eq(Invoice)
    end

    it 'raises ConfigurationError for non-class argument' do
      expect do
        Class.new(described_class) do
          model 'NotAClass'
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be an ActiveRecord model class/)
    end

    it 'raises ConfigurationError for wrong class hierarchy' do
      expect do
        Class.new(described_class) do
          model String
        end
      end.to raise_error(Apiwork::ConfigurationError, /must be an ActiveRecord model class/)
    end
  end

  describe '.model_class' do
    it 'returns the model class' do
      representation_class = Class.new(described_class) do
        model Invoice
      end

      expect(representation_class.model_class).to eq(Invoice)
    end
  end

  describe '.polymorphic_name' do
    context 'when type name is set' do
      it 'returns the polymorphic name' do
        representation_class = Class.new(described_class) do
          model Invoice
          type_name :receipt
        end

        expect(representation_class.polymorphic_name).to eq('receipt')
      end
    end

    context 'when type name is not set' do
      it 'returns the polymorphic name' do
        representation_class = Class.new(described_class) do
          model Invoice
        end

        expect(representation_class.polymorphic_name).to eq('Invoice')
      end
    end
  end

  describe '.root' do
    it 'sets the root key' do
      representation_class = Class.new(described_class) do
        model Invoice
        root :bill, :bills
      end

      root_key = representation_class.root_key
      expect(root_key.singular).to eq('bill')
      expect(root_key.plural).to eq('bills')
    end
  end

  describe '.root_key' do
    context 'when root is set' do
      it 'returns the root key' do
        representation_class = Class.new(described_class) do
          model Invoice
          root :bill, :bills
        end

        root_key = representation_class.root_key
        expect(root_key.singular).to eq('bill')
        expect(root_key.plural).to eq('bills')
      end
    end

    context 'when root is not set' do
      it 'returns the root key' do
        representation_class = Class.new(described_class) do
          model Invoice
        end

        root_key = representation_class.root_key
        expect(root_key.singular).to eq('invoice')
        expect(root_key.plural).to eq('invoices')
      end
    end
  end

  describe '.serialize' do
    context 'with single record' do
      it 'returns the serialized hash' do
        representation_class = Class.new(described_class) do
          model Invoice
          attribute :number
        end
        invoice = Invoice.new(number: 'INV-001')

        result = representation_class.serialize(invoice)

        expect(result).to include(number: 'INV-001')
      end
    end

    context 'with collection' do
      it 'returns the serialized array' do
        representation_class = Class.new(described_class) do
          model Invoice
          attribute :number
        end
        invoices = [Invoice.new(number: 'INV-001'), Invoice.new(number: 'INV-002')]

        result = representation_class.serialize(invoices)

        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result.first).to include(number: 'INV-001')
      end
    end
  end

  describe '.sti_name' do
    context 'when type name is set' do
      it 'returns the STI name' do
        representation_class = Class.new(described_class) do
          model Invoice
          type_name :receipt
        end

        expect(representation_class.sti_name).to eq('receipt')
      end
    end

    context 'when type name is not set' do
      it 'returns the STI name' do
        representation_class = Class.new(described_class) do
          model Invoice
        end

        expect(representation_class.sti_name).to eq('Invoice')
      end
    end
  end

  describe '.subclass?' do
    it 'returns true when subclass' do
      base = Class.new(described_class) do
        model Customer
      end
      sub = Class.new(base) do
        model PersonCustomer
      end
      inheritance = Apiwork::Representation::Inheritance.new(base)
      inheritance.register(sub)
      base.inheritance = inheritance

      expect(sub.subclass?).to be(true)
    end

    it 'returns false when not subclass' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class).not_to be_subclass
    end
  end

  describe '.type_name' do
    it 'returns the type name' do
      representation_class = Class.new(described_class) do
        abstract!
        type_name :receipt
      end

      expect(representation_class.type_name).to eq('receipt')
    end

    it 'returns nil when not set' do
      representation_class = Class.new(described_class) { abstract! }

      expect(representation_class.type_name).to be_nil
    end
  end

  describe '#initialize' do
    it 'creates with required attributes' do
      representation_class = Class.new(described_class) do
        model Invoice
      end
      invoice = Invoice.new(number: 'INV-001')

      representation = representation_class.new(invoice, context: { current_user: 'Alice' })

      expect(representation.record).to eq(invoice)
      expect(representation.context).to eq({ current_user: 'Alice' })
    end
  end
end
