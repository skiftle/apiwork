# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sorting types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }

  describe 'sort object' do
    let(:sort) { types[:invoice_sort] }

    it 'has type object' do
      expect(sort.type).to eq(:object)
    end

    it 'includes sortable attributes' do
      expect(sort.shape.keys).to include(:number, :status, :created_at, :due_on, :sent)
    end

    it 'excludes non-sortable attributes' do
      expect(sort.shape.keys).not_to include(:customer_id)
    end

    it 'references sort_direction for each attribute' do
      sort.shape.each_value do |param|
        expect(param.type).to eq(:reference)
        expect(param.reference).to eq(:sort_direction)
        expect(param.optional?).to be(true)
      end
    end
  end

  describe 'association sort' do
    let(:item_sort) { types[:item_sort] }

    it 'includes sortable association' do
      param = item_sort.shape[:invoice]

      expect(param.type).to eq(:reference)
      expect(param.optional?).to be(true)
    end
  end

  describe 'sort direction enum' do
    it 'has asc and desc values' do
      expect(introspection.enums[:sort_direction].values).to eq(%w[asc desc])
    end
  end
end
