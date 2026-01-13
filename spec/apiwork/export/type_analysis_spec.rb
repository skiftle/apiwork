# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export::TypeAnalysis do
  describe '.topological_sort_types' do
    it 'returns types in dependency order' do
      types = {
        address: { shape: { city: { type: :string } }, type: :object },
        user: { shape: { address: { type: :address }, name: { type: :string } }, type: :object },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names.index(:address)).to be < sorted_names.index(:user)
    end

    it 'handles types with no dependencies' do
      types = {
        color: { shape: { hex: { type: :string } }, type: :object },
        size: { shape: { value: { type: :integer } }, type: :object },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names).to contain_exactly(:color, :size)
    end

    it 'handles complex dependency chains' do
      types = {
        a: { shape: { b_ref: { type: :b } }, type: :object },
        b: { shape: { c_ref: { type: :c } }, type: :object },
        c: { shape: { value: { type: :string } }, type: :object },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names.index(:c)).to be < sorted_names.index(:b)
      expect(sorted_names.index(:b)).to be < sorted_names.index(:a)
    end

    it 'handles self-referencing types (skips self-references)' do
      types = {
        node: { shape: { children: { of: :node, type: :array } }, type: :object },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names).to eq([:node])
    end

    it 'handles circular references by including unsorted types at end' do
      types = {
        a: { shape: { b_ref: { type: :b } }, type: :object },
        b: { shape: { a_ref: { type: :a } }, type: :object },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names).to contain_exactly(:a, :b)
    end

    it 'handles union types with variants' do
      types = {
        bank: { shape: { routing: { type: :string } }, type: :object },
        card: { shape: { number: { type: :string } }, type: :object },
        payment: {
          type: :union,
          variants: [
            { type: :card },
            { type: :bank },
          ],
        },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names.index(:card)).to be < sorted_names.index(:payment)
      expect(sorted_names.index(:bank)).to be < sorted_names.index(:payment)
    end

    it 'handles array of custom types' do
      types = {
        item: { shape: { name: { type: :string } }, type: :object },
        order: { shape: { items: { of: :item, type: :array } }, type: :object },
      }

      sorted = described_class.topological_sort_types(types)
      sorted_names = sorted.map(&:first)

      expect(sorted_names.index(:item)).to be < sorted_names.index(:order)
    end
  end

  describe '.type_references' do
    it 'extracts type references from object shapes' do
      definition = {
        shape: {
          address: { type: :address },
          profile: { type: :profile },
        },
        type: :object,
      }

      refs = described_class.type_references(definition)

      expect(refs).to contain_exactly(:address, :profile)
    end

    it 'extracts references from array of custom types' do
      definition = {
        shape: {
          items: { of: :item, type: :array },
        },
        type: :object,
      }

      refs = described_class.type_references(definition)

      expect(refs).to include(:item)
    end

    it 'extracts references from union variants' do
      definition = {
        type: :union,
        variants: [
          { type: :card },
          { type: :bank },
        ],
      }

      refs = described_class.type_references(definition)

      expect(refs).to contain_exactly(:card, :bank)
    end

    it 'ignores primitive types with :custom_only filter' do
      definition = {
        shape: {
          active: { type: :boolean },
          count: { type: :integer },
          name: { type: :string },
        },
        type: :object,
      }

      refs = described_class.type_references(definition, filter: :custom_only)

      expect(refs).to be_empty
    end

    it 'filters to specific types with array filter' do
      definition = {
        shape: {
          address: { type: :address },
          other: { type: :other },
          profile: { type: :profile },
        },
        type: :object,
      }

      refs = described_class.type_references(definition, filter: %i[address profile])

      expect(refs).to contain_exactly(:address, :profile)
    end

    it 'extracts references from nested shapes' do
      definition = {
        shape: {
          nested: {
            shape: {
              deep_ref: { type: :deep_type },
            },
            type: :object,
          },
        },
        type: :object,
      }

      refs = described_class.type_references(definition)

      expect(refs).to include(:deep_type)
    end
  end

  describe '.circular_reference?' do
    it 'returns true for self-referencing types' do
      definition = {
        shape: {
          children: { of: :node, type: :array },
        },
        type: :object,
      }

      result = described_class.circular_reference?(:node, definition)

      expect(result).to be true
    end

    it 'returns false for types without self-reference' do
      definition = {
        shape: {
          address: { type: :address },
          name: { type: :string },
        },
        type: :object,
      }

      result = described_class.circular_reference?(:user, definition)

      expect(result).to be false
    end

    it 'detects reference via array of custom type' do
      definition = {
        shape: {
          items: { of: :tree, type: :array },
        },
        type: :object,
      }

      result = described_class.circular_reference?(:tree, definition)

      expect(result).to be true
    end

    it 'detects reference via direct type reference' do
      definition = {
        shape: {
          parent: { type: :category },
        },
        type: :object,
      }

      result = described_class.circular_reference?(:category, definition)

      expect(result).to be true
    end
  end

  describe '.primitive_type?' do
    it 'returns true for string' do
      expect(described_class.primitive_type?(:string)).to be true
    end

    it 'returns true for integer' do
      expect(described_class.primitive_type?(:integer)).to be true
    end

    it 'returns true for boolean' do
      expect(described_class.primitive_type?(:boolean)).to be true
    end

    it 'returns true for datetime' do
      expect(described_class.primitive_type?(:datetime)).to be true
    end

    it 'returns true for array' do
      expect(described_class.primitive_type?(:array)).to be true
    end

    it 'returns true for object' do
      expect(described_class.primitive_type?(:object)).to be true
    end

    it 'returns true for uuid' do
      expect(described_class.primitive_type?(:uuid)).to be true
    end

    it 'returns true for unknown' do
      expect(described_class.primitive_type?(:unknown)).to be true
    end

    it 'returns false for custom types' do
      expect(described_class.primitive_type?(:user)).to be false
      expect(described_class.primitive_type?(:address)).to be false
      expect(described_class.primitive_type?(:my_custom_type)).to be false
    end
  end
end
