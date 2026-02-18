# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Filtering types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }
  let(:enums) { introspection.enums }

  describe 'filter object' do
    let(:filter) { types[:invoice_filter] }

    it 'has type object' do
      expect(filter.type).to eq(:object)
    end

    it 'includes logical operators' do
      expect(filter.shape).to have_key(:AND)
      expect(filter.shape).to have_key(:OR)
      expect(filter.shape).to have_key(:NOT)
    end

    it 'has AND as optional array' do
      param = filter.shape[:AND]

      expect(param.type).to eq(:array)
      expect(param.optional?).to be(true)
    end

    it 'has NOT as optional reference' do
      param = filter.shape[:NOT]

      expect(param.type).to eq(:reference)
      expect(param.optional?).to be(true)
    end

    it 'includes filterable attributes' do
      expect(filter.shape.keys).to include(:number, :status, :created_at, :due_on, :sent)
    end

    it 'excludes non-filterable attributes' do
      expect(filter.shape.keys).not_to include(:customer_id)
    end
  end

  describe 'string attribute shorthand' do
    let(:param) { types[:invoice_filter].shape[:number] }

    it 'has type union' do
      expect(param.type).to eq(:union)
      expect(param.optional?).to be(true)
    end

    it 'has raw string variant and filter reference variant' do
      variant_types = param.variants.map { |v| v.respond_to?(:reference) ? v.reference : v.type }

      expect(variant_types).to include(:string)
      expect(variant_types).to include(:string_filter)
    end
  end

  describe 'nullable attribute shorthand' do
    let(:param) { types[:invoice_filter].shape[:notes] }

    it 'references nullable filter variant' do
      variant_types = param.variants.map { |v| v.respond_to?(:reference) ? v.reference : v.type }

      expect(variant_types).to include(:nullable_string_filter)
    end
  end

  describe 'enum attribute filter' do
    let(:param) { types[:invoice_filter].shape[:status] }

    it 'has type reference to enum filter' do
      expect(param.type).to eq(:reference)
      expect(param.optional?).to be(true)
    end
  end

  describe 'enum filter union' do
    let(:filter) { types[:invoice_status_filter] }

    it 'has type union' do
      expect(filter.type).to eq(:union)
    end

    it 'has enum reference variant' do
      variant_refs = filter.variants.select { |v| v.respond_to?(:reference) }.map(&:reference)

      expect(variant_refs).to include(:invoice_status)
    end
  end

  describe 'boolean attribute shorthand' do
    let(:param) { types[:invoice_filter].shape[:sent] }

    it 'has type union with boolean and filter reference' do
      variant_types = param.variants.map { |v| v.respond_to?(:reference) ? v.reference : v.type }

      expect(variant_types).to include(:boolean)
      expect(variant_types).to include(:nullable_boolean_filter)
    end
  end

  describe 'association filter' do
    let(:item_filter) { types[:item_filter] }

    it 'references parent resource filter type' do
      param = item_filter.shape[:invoice]

      expect(param.type).to eq(:reference)
      expect(param.optional?).to be(true)
    end
  end

  describe 'global filter types' do
    it 'includes string_filter with operators' do
      expect(types[:string_filter].shape.keys).to contain_exactly(:contains, :ends_with, :eq, :in, :starts_with)
    end

    it 'includes boolean_filter with eq operator' do
      expect(types[:boolean_filter].shape.keys).to contain_exactly(:eq)
    end

    it 'includes integer_filter with comparison operators' do
      expect(types[:integer_filter].shape.keys).to contain_exactly(:between, :eq, :gt, :gte, :in, :lt, :lte)
    end

    it 'includes date_filter with comparison operators' do
      expect(types[:date_filter].shape.keys).to contain_exactly(:between, :eq, :gt, :gte, :in, :lt, :lte)
    end

    it 'includes nullable variants with null operator' do
      expect(types[:nullable_string_filter].shape.keys).to include(:null)
      expect(types[:nullable_boolean_filter].shape.keys).to include(:null)
    end
  end

  describe 'between filter types' do
    it 'has from and to params' do
      expect(types[:date_filter_between].shape.keys).to contain_exactly(:from, :to)
      expect(types[:integer_filter_between].shape.keys).to contain_exactly(:from, :to)
    end
  end
end
