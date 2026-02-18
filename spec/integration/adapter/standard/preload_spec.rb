# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attribute preload', type: :request do
  let!(:customer1) { Customer.create!(email: 'billing@acme.com', name: 'Acme Corp') }
  let!(:invoice1) do
    Invoice.create!(customer: customer1, number: 'INV-001', status: :draft).tap do |invoice|
      invoice.items.create!(description: 'Consulting hours', quantity: 2, unit_price: 150.00)
      invoice.items.create!(description: 'Software license', quantity: 1, unit_price: 500.00)
    end
  end

  describe '.preloads' do
    it 'returns preload associations from attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: :items, type: :integer
        attribute :number, type: :string

        define_method(:item_count) do
          record.items.size
        end
      end

      expect(representation_class.preloads).to eq([:items])
    end

    it 'collects preloads from multiple attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: :items, type: :integer
        attribute :payment_count, preload: :payments, type: :integer

        define_method(:item_count) { record.items.size }
        define_method(:payment_count) { record.payments.size }
      end

      expect(representation_class.preloads).to eq([:items, :payments])
    end

    it 'collects nested preloads' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: { items: :adjustments }, type: :integer

        define_method(:item_count) { record.items.size }
      end

      expect(representation_class.preloads).to eq([{ items: :adjustments }])
    end

    it 'collects array preloads' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :summary, preload: [:items, :customer], type: :string

        define_method(:summary) { "#{record.items.size} items" }
      end

      expect(representation_class.preloads).to eq([[:items, :customer]])
    end

    it 'returns empty array when no preloads defined' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :number, type: :string
      end

      expect(representation_class.preloads).to eq([])
    end
  end

  describe 'preload via capability runner' do
    it 'adds preload associations to the query' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: :items, type: :integer

        define_method(:item_count) { record.items.size }
      end

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data).to be_a(ActiveRecord::Relation)
      expect(preloaded_data.includes_values).to include(:items)
    end

    it 'adds multiple preloads to the query' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: :items, type: :integer
        attribute :payment_count, preload: :payments, type: :integer

        define_method(:item_count) { record.items.size }
        define_method(:payment_count) { record.payments.size }
      end

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include(:items, :payments)
    end

    it 'adds nested preloads to the query' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: { items: :adjustments }, type: :integer

        define_method(:item_count) { record.items.size }
      end

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include({ items: :adjustments })
    end
  end
end
