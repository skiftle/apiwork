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

    context 'with self-referencing type' do
      it 'returns the self-referencing type' do
        all_types = {
          category: { shape: { parent: { reference: :category, type: :reference } }, type: :object },
        }

        result = described_class.cycle_breaking_types(all_types)

        expect(result).to contain_exactly(:category)
      end
    end

    context 'with triple cycle' do
      it 'returns one cycle-breaking type' do
        all_types = {
          customer: { shape: { invoice: { reference: :invoice, type: :reference } }, type: :object },
          invoice: { shape: { item: { reference: :item, type: :reference } }, type: :object },
          item: { shape: { customer: { reference: :customer, type: :reference } }, type: :object },
        }

        result = described_class.cycle_breaking_types(all_types)

        expect(result.size).to eq(1)
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

    context 'with long chain' do
      it 'sorts types in dependency order' do
        all_types = {
          adjustment: { shape: { item: { reference: :item, type: :reference } }, type: :object },
          customer: { shape: {}, type: :object },
          invoice: { shape: { customer: { reference: :customer, type: :reference } }, type: :object },
          item: { shape: { invoice: { reference: :invoice, type: :reference } }, type: :object },
        }

        result = described_class.topological_sort_types(all_types)
        names = result.map(&:first)

        expect(names.index(:customer)).to be < names.index(:invoice)
        expect(names.index(:invoice)).to be < names.index(:item)
        expect(names.index(:item)).to be < names.index(:adjustment)
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

    context 'with extends references' do
      it 'includes extended type names' do
        definition = { extends: [:base_record], shape: { title: { type: :string } }, type: :object }

        result = described_class.type_references(definition)

        expect(result).to include(:base_record)
      end
    end

    context 'with filter as array' do
      it 'only returns types matching the filter' do
        definition = {
          shape: {
            customer: { reference: :customer, type: :reference },
            name: { type: :string },
          },
          type: :object,
        }

        result = described_class.type_references(definition, filter: [:customer])

        expect(result).to eq([:customer])
      end
    end
  end

  describe '.primitive_type?' do
    it 'returns true for primitive types' do
      expect(described_class.primitive_type?(:string)).to be(true)
      expect(described_class.primitive_type?(:integer)).to be(true)
      expect(described_class.primitive_type?(:boolean)).to be(true)
      expect(described_class.primitive_type?(:unknown)).to be(true)
    end

    it 'returns false for custom types' do
      expect(described_class.primitive_type?(:invoice)).to be(false)
      expect(described_class.primitive_type?(:customer)).to be(false)
    end
  end
end
