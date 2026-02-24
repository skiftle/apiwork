# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::TypeRegistry::Definition do
  describe '#merge' do
    it 'returns the merged definition' do
      definition = described_class.new(:item, block: proc { |shape| shape.string :title }, kind: :object)

      merged = definition.merge(block: nil, deprecated: true, description: 'An item', example: nil)

      expect(merged.deprecated?).to be(true)
      expect(merged.description).to eq('An item')
    end

    context 'with block' do
      it 'returns the merged definition' do
        definition = described_class.new(:item, block: proc { |shape| shape.string :title }, kind: :object)

        merged = definition.merge(
          block: proc { |shape| shape.integer :amount },
          deprecated: false,
          description: nil,
          example: nil,
        )

        expect(merged.shape.params).to have_key(:title)
        expect(merged.shape.params).to have_key(:amount)
      end
    end
  end

  describe '#shape' do
    it 'returns the shape' do
      definition = described_class.new(:item, block: proc { |shape| shape.string :title }, kind: :object)

      result = definition.shape

      expect(result).to be_a(Apiwork::API::Object)
      expect(result.params).to have_key(:title)
    end

    context 'with union kind' do
      it 'returns the shape' do
        definition = described_class.new(
          :payment,
          block: proc { |shape| shape.variant(tag: 'card', &:string) },
          discriminator: :type,
          kind: :union,
        )

        result = definition.shape

        expect(result).to be_a(Apiwork::API::Union)
      end
    end
  end
end
