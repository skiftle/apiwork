# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Writing types', type: :integration do
  let(:introspection) { Apiwork::API.introspect('/api/v1') }
  let(:types) { introspection.types }

  describe 'create payload' do
    let(:payload) { types[:invoice_create_payload] }

    it 'has type object' do
      expect(payload.type).to eq(:object)
    end

    it 'includes writable attributes' do
      expect(payload.shape.keys).to include(:number, :sent, :status, :due_on, :notes, :customer_id, :metadata)
    end

    it 'has required attributes' do
      expect(payload.shape[:number].optional?).to be(false)
      expect(payload.shape[:customer_id].optional?).to be(false)
    end

    it 'has optional attributes' do
      expect(payload.shape[:notes].optional?).to be(true)
      expect(payload.shape[:due_on].optional?).to be(true)
    end

    it 'has enum reference for enum attributes' do
      expect(payload.shape[:status].enum?).to be(true)
      expect(payload.shape[:status].enum).to eq(:invoice_status)
    end

    it 'excludes non-writable attributes' do
      expect(payload.shape.keys).not_to include(:created_at, :updated_at, :id)
    end
  end

  describe 'update payload' do
    let(:payload) { types[:invoice_update_payload] }

    it 'has type object' do
      expect(payload.type).to eq(:object)
    end

    it 'has all writable attributes as optional' do
      payload.shape.each do |name, param|
        next if name == :items

        expect(param.optional?).to be(true), "expected #{name} to be optional"
      end
    end
  end

  describe 'create payload with writable association' do
    let(:payload) { types[:invoice_create_payload] }

    it 'has items as optional array of nested payload references' do
      param = payload.shape[:items]

      expect(param.type).to eq(:array)
      expect(param.optional?).to be(true)
      expect(param.of.type).to eq(:reference)
      expect(param.of.reference).to eq(:item_nested_payload)
    end
  end

  describe 'nested payload union' do
    let(:union) { types[:item_nested_payload] }

    it 'has type union' do
      expect(union.type).to eq(:union)
    end

    it 'has OP discriminator' do
      expect(union.discriminator).to eq(:OP)
    end

    it 'has three variants' do
      variant_refs = union.variants.map(&:reference)

      expect(variant_refs).to contain_exactly(
        :item_nested_create_payload,
        :item_nested_update_payload,
        :item_nested_delete_payload,
      )
    end
  end

  describe 'nested create payload' do
    let(:payload) { types[:item_nested_create_payload] }

    it 'has type object' do
      expect(payload.type).to eq(:object)
    end

    it 'has OP literal with create value' do
      param = payload.shape[:OP]

      expect(param.type).to eq(:literal)
      expect(param.value).to eq('create')
      expect(param.optional?).to be(true)
    end

    it 'has optional id' do
      expect(payload.shape[:id].type).to eq(:integer)
      expect(payload.shape[:id].optional?).to be(true)
    end

    it 'includes writable fields' do
      expect(payload.shape.keys).to include(:description, :invoice_id, :quantity, :unit_price)
    end
  end

  describe 'nested update payload' do
    let(:payload) { types[:item_nested_update_payload] }

    it 'has OP literal with update value' do
      expect(payload.shape[:OP].type).to eq(:literal)
      expect(payload.shape[:OP].value).to eq('update')
    end

    it 'has optional id' do
      expect(payload.shape[:id].optional?).to be(true)
    end

    it 'includes writable fields' do
      expect(payload.shape.keys).to include(:description, :invoice_id, :quantity, :unit_price)
    end
  end

  describe 'nested delete payload' do
    let(:payload) { types[:item_nested_delete_payload] }

    it 'has only OP and id fields' do
      expect(payload.shape.keys).to contain_exactly(:OP, :id)
    end

    it 'has OP literal with delete value' do
      expect(payload.shape[:OP].type).to eq(:literal)
      expect(payload.shape[:OP].value).to eq('delete')
    end

    it 'has required id' do
      expect(payload.shape[:id].type).to eq(:integer)
      expect(payload.shape[:id].optional?).to be(false)
    end
  end

  describe 'deep nesting' do
    it 'has adjustments array in item nested create payload' do
      param = types[:item_nested_create_payload].shape[:adjustments]

      expect(param.type).to eq(:array)
      expect(param.of.reference).to eq(:adjustment_nested_payload)
    end

    it 'has adjustment nested payload union' do
      union = types[:adjustment_nested_payload]

      expect(union.type).to eq(:union)
      expect(union.discriminator).to eq(:OP)
    end

    it 'has adjustment nested create payload with writable fields' do
      payload = types[:adjustment_nested_create_payload]

      expect(payload.shape.keys).to include(:OP, :id, :amount, :description)
    end

    it 'has adjustment nested delete payload with only OP and id' do
      payload = types[:adjustment_nested_delete_payload]

      expect(payload.shape.keys).to contain_exactly(:OP, :id)
    end
  end

  describe 'STI payloads' do
    it 'has customer create payload as union with type discriminator' do
      union = types[:customer_create_payload]

      expect(union.type).to eq(:union)
      expect(union.discriminator).to eq(:type)
    end

    it 'has company and person create payload variants' do
      variant_refs = types[:customer_create_payload].variants.map(&:reference)

      expect(variant_refs).to contain_exactly(
        :company_customer_create_payload,
        :person_customer_create_payload,
      )
    end

    it 'has customer update payload as union with type discriminator' do
      union = types[:customer_update_payload]

      expect(union.type).to eq(:union)
      expect(union.discriminator).to eq(:type)
    end
  end
end
