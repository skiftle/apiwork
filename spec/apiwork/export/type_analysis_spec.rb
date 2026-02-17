# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::TypeAnalysis do
  describe '.cycle_breaking_types' do
    it 'returns the cycle-breaking types' do
      all_types = {
        invoice: { shape: { item: { reference: :item, type: :reference } }, type: :object },
        item: { shape: { invoice: { reference: :invoice, type: :reference } }, type: :object },
      }

      result = described_class.cycle_breaking_types(all_types)

      expect(result).to be_a(Set)
      expect(result.size).to eq(1)
    end

    context 'without cycles' do
      it 'returns an empty set' do
        all_types = {
          invoice: { shape: { item: { reference: :item, type: :reference } }, type: :object },
          item: { shape: {}, type: :object },
        }

        result = described_class.cycle_breaking_types(all_types)

        expect(result).to be_empty
      end
    end
  end

  describe '.topological_sort_types' do
    it 'returns types in dependency order' do
      all_types = {
        invoice: { shape: { item: { reference: :item, type: :reference } }, type: :object },
        item: { shape: {}, type: :object },
      }

      result = described_class.topological_sort_types(all_types)

      names = result.map(&:first)
      expect(names.index(:item)).to be < names.index(:invoice)
    end

    context 'with cyclic dependencies' do
      it 'returns types in dependency order' do
        all_types = {
          customer: { shape: {}, type: :object },
          invoice: { shape: { item: { reference: :item, type: :reference } }, type: :object },
          item: { shape: { invoice: { reference: :invoice, type: :reference } }, type: :object },
        }

        result = described_class.topological_sort_types(all_types)

        names = result.map(&:first)
        expect(names).to contain_exactly(:customer, :invoice, :item)
      end
    end
  end

  describe '.type_references' do
    it 'returns the type references' do
      definition = { shape: { customer: { reference: :customer, type: :reference } }, type: :object }

      result = described_class.type_references(definition)

      expect(result).to eq([:customer])
    end

    context 'without references' do
      it 'returns an empty array' do
        definition = { shape: { title: { type: :string } }, type: :object }

        result = described_class.type_references(definition)

        expect(result).to be_empty
      end
    end
  end
end
