# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Base do
  describe '.deserialize' do
    let(:representation_class) do
      Class.new(described_class) do
        abstract!

        attribute :title, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }, type: :string
        attribute :notes, empty: true, type: :string
        attribute :count, type: :integer
      end
    end

    it 'returns nil for nil input' do
      expect(representation_class.deserialize(nil)).to be_nil
    end

    it 'returns hash unchanged when no transformers defined' do
      result = representation_class.deserialize({ count: 42, title: 'Hello' })

      expect(result[:title]).to eq('Hello')
      expect(result[:count]).to eq(42)
    end

    it 'applies decode transformer to attribute' do
      result = representation_class.deserialize({ email: '  USER@EXAMPLE.COM  ' })

      expect(result[:email]).to eq('user@example.com')
    end

    it 'applies empty: true transformer (blank to nil)' do
      result = representation_class.deserialize({ notes: '' })

      expect(result[:notes]).to be_nil
    end

    it 'preserves non-empty values with empty: true' do
      result = representation_class.deserialize({ notes: 'Some notes' })

      expect(result[:notes]).to eq('Some notes')
    end

    it 'ignores keys not in attributes' do
      result = representation_class.deserialize({ title: 'Hello', unknown_key: 'ignored' })

      expect(result[:title]).to eq('Hello')
      expect(result[:unknown_key]).to eq('ignored')
    end

    it 'handles array input' do
      result = representation_class.deserialize(
        [
          { email: 'ONE@EXAMPLE.COM' },
          { email: 'TWO@EXAMPLE.COM' },
        ],
      )

      expect(result).to be_an(Array)
      expect(result[0][:email]).to eq('one@example.com')
      expect(result[1][:email]).to eq('two@example.com')
    end

    it 'handles empty array' do
      result = representation_class.deserialize([])

      expect(result).to eq([])
    end

    it 'returns non-hash values unchanged' do
      result = representation_class.deserialize('not a hash')

      expect(result).to eq('not a hash')
    end
  end

  describe '.deserialize_hash' do
    let(:representation_class) do
      Class.new(described_class) do
        abstract!

        attribute :title, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }, type: :string
        attribute :notes, empty: true, type: :string
      end
    end

    it 'applies all decode transformers' do
      result = representation_class.deserialize_hash(
        {
          email: '  UPPER@TEST.COM  ',
          notes: '',
          title: 'Test',
        },
      )

      expect(result[:title]).to eq('Test')
      expect(result[:email]).to eq('upper@test.com')
      expect(result[:notes]).to be_nil
    end

    it 'does not modify original hash' do
      original = { email: '  UPPER@TEST.COM  ' }
      representation_class.deserialize_hash(original)

      expect(original[:email]).to eq('  UPPER@TEST.COM  ')
    end
  end

  describe 'nested associations' do
    let(:line_representation) do
      Class.new(described_class) do
        abstract!
        attribute :description, type: :string
        attribute :amount, decode: ->(v) { BigDecimal(v.to_s) }
      end
    end

    let(:customer_representation) do
      Class.new(described_class) do
        abstract!
        attribute :name, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }
      end
    end

    let(:invoice_representation) do
      line = line_representation
      customer = customer_representation
      Class.new(described_class) do
        abstract!
        attribute :number, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }
        has_many :lines, representation: line
        has_one :customer, representation: customer
      end
    end

    it 'deserializes nested has_many associations' do
      input = {
        email: '  USER@EXAMPLE.COM  ',
        lines: [
          { amount: '99.99', description: 'Widget' },
          { amount: '49.99', description: 'Gadget' },
        ],
        number: 'INV-001',
      }

      result = invoice_representation.deserialize(input)

      expect(result[:email]).to eq('user@example.com')
      expect(result[:lines][0][:amount]).to eq(BigDecimal('99.99'))
      expect(result[:lines][1][:amount]).to eq(BigDecimal('49.99'))
    end

    it 'deserializes nested has_one associations' do
      input = {
        customer: { email: '  ACME@EXAMPLE.COM  ', name: 'Acme' },
        number: 'INV-001',
      }

      result = invoice_representation.deserialize(input)

      expect(result[:customer][:email]).to eq('acme@example.com')
    end

    it 'handles nil association values' do
      input = {
        customer: nil,
        lines: nil,
        number: 'INV-001',
      }

      result = invoice_representation.deserialize(input)

      expect(result[:customer]).to be_nil
      expect(result[:lines]).to be_nil
    end

    it 'handles empty array for has_many' do
      input = { lines: [], number: 'INV-001' }

      result = invoice_representation.deserialize(input)

      expect(result[:lines]).to eq([])
    end

    it 'skips associations without representation_class' do
      representation_without_explicit = Class.new(described_class) do
        abstract!
        attribute :title, type: :string
      end

      result = representation_without_explicit.deserialize({ title: 'Test' })

      expect(result[:title]).to eq('Test')
    end
  end

  describe Apiwork::Representation::Attribute do
    let(:representation_class) do
      Class.new(Apiwork::Representation::Base) do
        abstract!
      end
    end

    describe 'with inline object shape' do
      it 'stores the element as element' do
        definition = described_class.new(:settings, representation_class) do
          object do
            string :theme
          end
        end

        expect(definition.element).to be_a(Apiwork::Representation::Element)
        expect(definition.element.type).to eq(:object)
      end

      it 'infers type as :object when object block provided' do
        definition = described_class.new(:settings, representation_class) do
          object do
            string :theme
          end
        end

        expect(definition.type).to eq(:object)
      end

      it 'infers type as :array when array block provided' do
        definition = described_class.new(:tags, representation_class) do
          array do
            string
          end
        end

        expect(definition.type).to eq(:array)
        expect(definition.of).to eq(:string)
      end
    end

    describe 'with array of primitives' do
      it 'stores the element type via block' do
        definition = described_class.new(:tags, representation_class) do
          array do
            string
          end
        end

        expect(definition.of).to eq(:string)
        expect(definition.type).to eq(:array)
        expect(definition.element).to be_a(Apiwork::Representation::Element)
      end
    end

    describe 'with array of objects' do
      it 'stores type and element' do
        definition = described_class.new(:line_items, representation_class) do
          array do
            object do
              string :name
              decimal :price
            end
          end
        end

        expect(definition.type).to eq(:array)
        expect(definition.element).to be_a(Apiwork::Representation::Element)
        expect(definition.element.of_type).to eq(:object)
      end
    end

    describe 'without inline shape' do
      it 'has nil element' do
        definition = described_class.new(:metadata, representation_class, type: :unknown)

        expect(definition.element).to be_nil
        expect(definition.type).to eq(:unknown)
      end
    end
  end

  describe 'custom methods' do
    let(:item_representation) do
      Class.new(described_class) do
        abstract!
        attribute :name, type: :string
        attribute :amount, type: :decimal
      end
    end

    let(:customer_representation) do
      Class.new(described_class) do
        abstract!
        attribute :name, type: :string
      end
    end

    describe 'attribute custom method' do
      it 'uses custom method when defined on representation' do
        representation_class = Class.new(described_class) do
          abstract!

          attribute :total, type: :decimal

          def total
            record.items.sum(&:amount)
          end
        end

        items = [
          double(:item, amount: BigDecimal('10.00')),
          double(:item, amount: BigDecimal('20.00')),
        ]
        record = double(:record, items:, total: BigDecimal('999.00'))

        result = representation_class.new(record).as_json

        expect(result[:total]).to eq(BigDecimal('30.00'))
      end

      it 'falls back to record method when no custom method defined' do
        representation_class = Class.new(described_class) do
          abstract!

          attribute :total, type: :decimal
        end

        record = double(:record, total: BigDecimal('50.00'))

        result = representation_class.new(record).as_json

        expect(result[:total]).to eq(BigDecimal('50.00'))
      end
    end

    describe 'has_one custom method' do
      it 'uses custom method when defined on representation' do
        customer = customer_representation
        default_customer = double(:default_customer, name: 'Default Customer')

        representation_class = Class.new(described_class) do
          abstract!
          has_one :customer, representation: customer

          define_method(:customer) do
            record.customer || default_customer
          end
        end

        record = double(:record, customer: nil)

        result = representation_class.new(record, include: :customer).as_json

        expect(result[:customer][:name]).to eq('Default Customer')
      end

      it 'falls back to record method when no custom method defined' do
        customer = customer_representation

        representation_class = Class.new(described_class) do
          abstract!
          has_one :customer, representation: customer
        end

        customer_record = double(:customer, name: 'Acme Inc')
        record = double(:record, customer: customer_record)

        result = representation_class.new(record, include: :customer).as_json

        expect(result[:customer][:name]).to eq('Acme Inc')
      end
    end

    describe 'has_many custom method' do
      it 'uses custom method when defined on representation' do
        item = item_representation

        representation_class = Class.new(described_class) do
          abstract!
          has_many :items, representation: item

          def items
            record.items.first(2)
          end
        end

        all_items = [
          double(:item, amount: 10, name: 'Item 1'),
          double(:item, amount: 20, name: 'Item 2'),
          double(:item, amount: 30, name: 'Item 3'),
        ]
        record = double(:record, items: all_items)

        result = representation_class.new(record, include: :items).as_json

        expect(result[:items].size).to eq(2)
        expect(result[:items][0][:name]).to eq('Item 1')
        expect(result[:items][1][:name]).to eq('Item 2')
      end

      it 'falls back to record method when no custom method defined' do
        item = item_representation

        representation_class = Class.new(described_class) do
          abstract!
          has_many :items, representation: item
        end

        all_items = [
          double(:item, amount: 10, name: 'Item 1'),
          double(:item, amount: 20, name: 'Item 2'),
        ]
        record = double(:record, items: all_items)

        result = representation_class.new(record, include: :items).as_json

        expect(result[:items].size).to eq(2)
      end
    end

    describe 'belongs_to custom method' do
      it 'uses custom method when defined on representation' do
        customer = customer_representation
        default_customer = double(:default_customer, name: 'Unknown')

        representation_class = Class.new(described_class) do
          abstract!
          belongs_to :customer, representation: customer

          define_method(:customer) do
            record.customer || default_customer
          end
        end

        record = double(:record, customer: nil)

        result = representation_class.new(record, include: :customer).as_json

        expect(result[:customer][:name]).to eq('Unknown')
      end

      it 'falls back to record method when no custom method defined' do
        customer = customer_representation

        representation_class = Class.new(described_class) do
          abstract!
          belongs_to :customer, representation: customer
        end

        customer_record = double(:customer, name: 'Acme Inc')
        record = double(:record, customer: customer_record)

        result = representation_class.new(record, include: :customer).as_json

        expect(result[:customer][:name]).to eq('Acme Inc')
      end
    end
  end

  describe '.attribute' do
    it 'passes block to Attribute' do
      representation_class = Class.new(described_class) do
        abstract!

        attribute :settings do
          object do
            string :theme
          end
        end
      end

      definition = representation_class.attributes[:settings]

      expect(definition.element).to be_a(Apiwork::Representation::Element)
      expect(definition.type).to eq(:object)
    end

    it 'stores element type for arrays via block' do
      representation_class = Class.new(described_class) do
        abstract!

        attribute :tags do
          array do
            string
          end
        end
      end

      definition = representation_class.attributes[:tags]

      expect(definition.type).to eq(:array)
      expect(definition.of).to eq(:string)
    end
  end

  describe 'preload option' do
    describe 'Attribute#preload' do
      it 'stores simple preload' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :total, preload: :items, type: :decimal
        end

        expect(representation_class.attributes[:total].preload).to eq(:items)
      end

      it 'stores array preload' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :total, preload: [:items, :customer], type: :decimal
        end

        expect(representation_class.attributes[:total].preload).to eq([:items, :customer])
      end

      it 'stores nested preload' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :total, preload: { items: :tax_rates }, type: :decimal
        end

        expect(representation_class.attributes[:total].preload).to eq({ items: :tax_rates })
      end

      it 'defaults to nil' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :name, type: :string
        end

        expect(representation_class.attributes[:name].preload).to be_nil
      end
    end

    describe '.preloads' do
      it 'collects preloads from all attributes' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :name, type: :string
          attribute :total, preload: :items, type: :decimal
          attribute :tax, preload: { items: :tax_rates }, type: :decimal
        end

        expect(representation_class.preloads).to contain_exactly(:items, { items: :tax_rates })
      end

      it 'returns empty array when no preloads' do
        representation_class = Class.new(described_class) do
          abstract!
          attribute :name, type: :string
        end

        expect(representation_class.preloads).to eq([])
      end
    end
  end
end
