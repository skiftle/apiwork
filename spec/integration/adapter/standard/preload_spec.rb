# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Attribute preload', type: :integration do
  describe 'preloads associations for custom attribute methods' do
    it 'includes preload associations in query' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: :items, type: :integer
        attribute :number, type: :string

        define_method(:item_count) do
          record.items.size
        end
      end

      expect(representation_class.preloads).to eq([:items])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data).to be_a(ActiveRecord::Relation)
      expect(preloaded_data.includes_values).to include(:items)
    end

    it 'handles multiple preloads from different attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: :items, type: :integer
        attribute :payment_count, preload: :payments, type: :integer

        define_method(:item_count) do
          record.items.size
        end

        define_method(:payment_count) do
          record.payments.size
        end
      end

      expect(representation_class.preloads).to eq([:items, :payments])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include(:items, :payments)
    end

    it 'handles nested preloads' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :item_count, preload: { items: :adjustments }, type: :integer

        define_method(:item_count) do
          record.items.size
        end
      end

      expect(representation_class.preloads).to eq([{ items: :adjustments }])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include({ items: :adjustments })
    end

    it 'handles array preloads' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :summary, preload: [:items, :customer], type: :string

        define_method(:summary) do
          "#{record.items.size} items for #{record.customer.name}"
        end
      end

      expect(representation_class.preloads).to eq([[:items, :customer]])

      runner = Apiwork::Adapter::Capability::Runner.new([], wrapper_type: :member)
      relation = Invoice.all

      preloaded_data, = runner.run(relation, representation_class, double(:request))

      expect(preloaded_data.includes_values).to include(:items, :customer)
    end

    it 'returns empty array when no preloads defined' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        abstract!
        attribute :number, type: :string
      end

      expect(representation_class.preloads).to eq([])
    end
  end
end
