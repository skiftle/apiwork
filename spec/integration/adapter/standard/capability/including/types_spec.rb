# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Including types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }

  describe 'include object' do
    let(:include_type) { types[:invoice_include] }

    it 'has type object' do
      expect(include_type.type).to eq(:object)
    end

    it 'includes all associations' do
      expect(include_type.shape.keys).to contain_exactly(:attachments, :items, :payments, :taggings)
    end
  end

  describe 'association without nested includes' do
    let(:param) { types[:invoice_include].shape[:attachments] }

    it 'has type boolean' do
      expect(param.type).to eq(:boolean)
      expect(param.optional?).to be(true)
    end
  end

  describe 'association with nested includes' do
    let(:param) { types[:invoice_include].shape[:items] }

    it 'has type union of boolean and include reference' do
      expect(param.type).to eq(:union)
      expect(param.optional?).to be(true)
    end

    it 'has boolean variant' do
      boolean_variant = param.variants.find { |v| v.type == :boolean }

      expect(boolean_variant).not_to be_nil
    end

    it 'has reference variant to nested include type' do
      ref_variant = param.variants.find { |v| v.respond_to?(:reference) }

      expect(ref_variant).not_to be_nil
      expect(ref_variant.reference).to eq(:item_include)
    end
  end

  describe 'nested include object' do
    let(:item_include) { types[:item_include] }

    it 'has type object' do
      expect(item_include.type).to eq(:object)
    end

    it 'includes item associations' do
      expect(item_include.shape.keys).to contain_exactly(:adjustments, :invoice)
    end

    it 'has boolean params for leaf associations' do
      expect(item_include.shape[:adjustments].type).to eq(:boolean)
      expect(item_include.shape[:invoice].type).to eq(:boolean)
    end
  end
end
