# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Schema::Base do
  describe '.deserialize' do
    let(:schema_class) do
      Class.new(described_class) do
        abstract!

        attribute :title, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }, type: :string
        attribute :notes, empty: true, type: :string
        attribute :count, type: :integer
      end
    end

    it 'returns nil for nil input' do
      expect(schema_class.deserialize(nil)).to be_nil
    end

    it 'returns hash unchanged when no transformers defined' do
      result = schema_class.deserialize({ count: 42, title: 'Hello' })

      expect(result[:title]).to eq('Hello')
      expect(result[:count]).to eq(42)
    end

    it 'applies decode transformer to attribute' do
      result = schema_class.deserialize({ email: '  USER@EXAMPLE.COM  ' })

      expect(result[:email]).to eq('user@example.com')
    end

    it 'applies empty: true transformer (blank to nil)' do
      result = schema_class.deserialize({ notes: '' })

      expect(result[:notes]).to be_nil
    end

    it 'preserves non-empty values with empty: true' do
      result = schema_class.deserialize({ notes: 'Some notes' })

      expect(result[:notes]).to eq('Some notes')
    end

    it 'ignores keys not in attributes' do
      result = schema_class.deserialize({ title: 'Hello', unknown_key: 'ignored' })

      expect(result[:title]).to eq('Hello')
      expect(result[:unknown_key]).to eq('ignored')
    end

    it 'handles array input' do
      result = schema_class.deserialize(
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
      result = schema_class.deserialize([])

      expect(result).to eq([])
    end

    it 'returns non-hash values unchanged' do
      result = schema_class.deserialize('not a hash')

      expect(result).to eq('not a hash')
    end
  end

  describe '.deserialize_hash' do
    let(:schema_class) do
      Class.new(described_class) do
        abstract!

        attribute :title, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }, type: :string
        attribute :notes, empty: true, type: :string
      end
    end

    it 'applies all decode transformers' do
      result = schema_class.deserialize_hash(
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
      schema_class.deserialize_hash(original)

      expect(original[:email]).to eq('  UPPER@TEST.COM  ')
    end
  end

  describe 'nested associations' do
    let(:line_schema) do
      Class.new(described_class) do
        abstract!
        attribute :description, type: :string
        attribute :amount, decode: ->(v) { BigDecimal(v.to_s) }
      end
    end

    let(:customer_schema) do
      Class.new(described_class) do
        abstract!
        attribute :name, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }
      end
    end

    let(:invoice_schema) do
      line = line_schema
      customer = customer_schema
      Class.new(described_class) do
        abstract!
        attribute :number, type: :string
        attribute :email, decode: ->(v) { v&.downcase&.strip }
        has_many :lines, schema: line
        has_one :customer, schema: customer
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

      result = invoice_schema.deserialize(input)

      expect(result[:email]).to eq('user@example.com')
      expect(result[:lines][0][:amount]).to eq(BigDecimal('99.99'))
      expect(result[:lines][1][:amount]).to eq(BigDecimal('49.99'))
    end

    it 'deserializes nested has_one associations' do
      input = {
        customer: { email: '  ACME@EXAMPLE.COM  ', name: 'Acme' },
        number: 'INV-001',
      }

      result = invoice_schema.deserialize(input)

      expect(result[:customer][:email]).to eq('acme@example.com')
    end

    it 'handles nil association values' do
      input = {
        customer: nil,
        lines: nil,
        number: 'INV-001',
      }

      result = invoice_schema.deserialize(input)

      expect(result[:customer]).to be_nil
      expect(result[:lines]).to be_nil
    end

    it 'handles empty array for has_many' do
      input = { lines: [], number: 'INV-001' }

      result = invoice_schema.deserialize(input)

      expect(result[:lines]).to eq([])
    end

    it 'skips associations without schema_class' do
      schema_without_explicit = Class.new(described_class) do
        abstract!
        attribute :title, type: :string
      end

      result = schema_without_explicit.deserialize({ title: 'Test' })

      expect(result[:title]).to eq('Test')
    end
  end

  describe Apiwork::Schema::Attribute do
    let(:schema_class) do
      Class.new(Apiwork::Schema::Base) do
        abstract!
      end
    end

    describe 'with inline object shape' do
      it 'stores the element as inline_element' do
        definition = described_class.new(:settings, schema_class) do
          object do
            string :theme
          end
        end

        expect(definition.inline_element).to be_a(Apiwork::Schema::Element)
        expect(definition.inline_element.type).to eq(:object)
      end

      it 'infers type as :object when object block provided' do
        definition = described_class.new(:settings, schema_class) do
          object do
            string :theme
          end
        end

        expect(definition.type).to eq(:object)
      end

      it 'infers type as :array when array block provided' do
        definition = described_class.new(:tags, schema_class) do
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
        definition = described_class.new(:tags, schema_class) do
          array do
            string
          end
        end

        expect(definition.of).to eq(:string)
        expect(definition.type).to eq(:array)
        expect(definition.inline_element).to be_a(Apiwork::Schema::Element)
      end
    end

    describe 'with array of objects' do
      it 'stores type and inline_element' do
        definition = described_class.new(:line_items, schema_class) do
          array do
            object do
              string :name
              decimal :price
            end
          end
        end

        expect(definition.type).to eq(:array)
        expect(definition.inline_element).to be_a(Apiwork::Schema::Element)
        expect(definition.inline_element.of_type).to eq(:object)
      end
    end

    describe 'without inline shape' do
      it 'has nil inline_element' do
        definition = described_class.new(:metadata, schema_class, type: :json)

        expect(definition.inline_element).to be_nil
        expect(definition.type).to eq(:json)
      end
    end
  end

  describe '.attribute' do
    it 'passes block to Attribute' do
      schema_class = Class.new(described_class) do
        abstract!

        attribute :settings do
          object do
            string :theme
          end
        end
      end

      definition = schema_class.attributes[:settings]

      expect(definition.inline_element).to be_a(Apiwork::Schema::Element)
      expect(definition.type).to eq(:object)
    end

    it 'stores element type for arrays via block' do
      schema_class = Class.new(described_class) do
        abstract!

        attribute :tags do
          array do
            string
          end
        end
      end

      definition = schema_class.attributes[:tags]

      expect(definition.type).to eq(:array)
      expect(definition.of).to eq(:string)
    end
  end
end
