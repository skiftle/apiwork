# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Representation::Serializer do
  let(:item_representation) do
    Class.new(Apiwork::Representation::Base) do
      abstract!
      attribute :name, type: :string
      attribute :amount, type: :decimal
    end
  end

  let(:customer_representation) do
    Class.new(Apiwork::Representation::Base) do
      abstract!
      attribute :name, type: :string
    end
  end

  describe 'attribute custom method' do
    it 'uses custom method when defined on representation' do
      representation_class = Class.new(Apiwork::Representation::Base) do
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

      result = described_class.new(representation_class.new(record), nil).serialize

      expect(result[:total]).to eq(BigDecimal('30.00'))
    end

    it 'falls back to record method when no custom method defined' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!

        attribute :total, type: :decimal
      end

      record = double(:record, total: BigDecimal('50.00'))

      result = described_class.new(representation_class.new(record), nil).serialize

      expect(result[:total]).to eq(BigDecimal('50.00'))
    end
  end

  describe 'has_one custom method' do
    it 'uses custom method when defined on representation' do
      customer = customer_representation
      default_customer = double(:default_customer, name: 'Default Customer')

      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        has_one :customer, representation: customer

        define_method(:customer) do
          record.customer || default_customer
        end
      end

      record = double(:record, customer: nil)

      result = described_class.new(representation_class.new(record, include: :customer), :customer).serialize

      expect(result[:customer][:name]).to eq('Default Customer')
    end

    it 'falls back to record method when no custom method defined' do
      customer = customer_representation

      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        has_one :customer, representation: customer
      end

      customer_record = double(:customer, name: 'Acme Inc')
      record = double(:record, customer: customer_record)

      result = described_class.new(representation_class.new(record, include: :customer), :customer).serialize

      expect(result[:customer][:name]).to eq('Acme Inc')
    end
  end

  describe 'has_many custom method' do
    it 'uses custom method when defined on representation' do
      item = item_representation

      representation_class = Class.new(Apiwork::Representation::Base) do
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

      result = described_class.new(representation_class.new(record, include: :items), :items).serialize

      expect(result[:items].size).to eq(2)
      expect(result[:items][0][:name]).to eq('Item 1')
      expect(result[:items][1][:name]).to eq('Item 2')
    end

    it 'falls back to record method when no custom method defined' do
      item = item_representation

      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        has_many :items, representation: item
      end

      all_items = [
        double(:item, amount: 10, name: 'Item 1'),
        double(:item, amount: 20, name: 'Item 2'),
      ]
      record = double(:record, items: all_items)

      result = described_class.new(representation_class.new(record, include: :items), :items).serialize

      expect(result[:items].size).to eq(2)
    end
  end

  describe 'belongs_to custom method' do
    it 'uses custom method when defined on representation' do
      customer = customer_representation
      default_customer = double(:default_customer, name: 'Unknown')

      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        belongs_to :customer, representation: customer

        define_method(:customer) do
          record.customer || default_customer
        end
      end

      record = double(:record, customer: nil)

      result = described_class.new(representation_class.new(record, include: :customer), :customer).serialize

      expect(result[:customer][:name]).to eq('Unknown')
    end

    it 'falls back to record method when no custom method defined' do
      customer = customer_representation

      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        belongs_to :customer, representation: customer
      end

      customer_record = double(:customer, name: 'Acme Inc')
      record = double(:record, customer: customer_record)

      result = described_class.new(representation_class.new(record, include: :customer), :customer).serialize

      expect(result[:customer][:name]).to eq('Acme Inc')
    end
  end
end
