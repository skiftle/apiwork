# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OpenAPI discriminated union generation', type: :integration do
  let(:path) { '/api/v1' }
  let(:generator) { Apiwork::Export::OpenAPI.new(path) }
  let(:spec) { generator.generate }

  describe 'Nested payload unions' do
    it 'generates oneOf for item nested payload variants' do
      payload = spec[:components][:schemas]['item_nested_payload']

      expect(payload[:oneOf].length).to eq(3)
    end

    it 'generates discriminator with propertyName' do
      payload = spec[:components][:schemas]['item_nested_payload']

      expect(payload[:discriminator][:propertyName]).to eq('OP')
    end

    it 'generates discriminator mapping to $ref schemas' do
      payload = spec[:components][:schemas]['item_nested_payload']
      mapping = payload[:discriminator][:mapping]

      expect(mapping['create']).to eq('#/components/schemas/item_nested_create_payload')
      expect(mapping['update']).to eq('#/components/schemas/item_nested_update_payload')
      expect(mapping['delete']).to eq('#/components/schemas/item_nested_delete_payload')
    end

    it 'generates oneOf variants as $ref entries' do
      payload = spec[:components][:schemas]['item_nested_payload']
      refs = payload[:oneOf].map { |variant| variant[:'$ref'] }

      expect(refs).to contain_exactly(
        '#/components/schemas/item_nested_create_payload',
        '#/components/schemas/item_nested_update_payload',
        '#/components/schemas/item_nested_delete_payload',
      )
    end
  end

  describe 'Literal type fields' do
    it 'generates const value for discriminator field in create variant' do
      create_payload = spec[:components][:schemas]['item_nested_create_payload']
      op_field = create_payload[:properties]['OP']

      expect(op_field[:const]).to eq('create')
      expect(op_field[:type]).to eq('string')
    end

    it 'generates const value for discriminator field in update variant' do
      update_payload = spec[:components][:schemas]['item_nested_update_payload']
      op_field = update_payload[:properties]['OP']

      expect(op_field[:const]).to eq('update')
      expect(op_field[:type]).to eq('string')
    end

    it 'generates const value for discriminator field in delete variant' do
      delete_payload = spec[:components][:schemas]['item_nested_delete_payload']
      op_field = delete_payload[:properties]['OP']

      expect(op_field[:const]).to eq('delete')
      expect(op_field[:type]).to eq('string')
    end
  end

  describe 'Adjustment nested payload union' do
    it 'generates oneOf for adjustment nested payload variants' do
      payload = spec[:components][:schemas]['adjustment_nested_payload']

      expect(payload[:oneOf].length).to eq(3)
    end

    it 'generates discriminator mapping for adjustment variants' do
      payload = spec[:components][:schemas]['adjustment_nested_payload']
      mapping = payload[:discriminator][:mapping]

      expect(mapping['create']).to eq('#/components/schemas/adjustment_nested_create_payload')
      expect(mapping['update']).to eq('#/components/schemas/adjustment_nested_update_payload')
      expect(mapping['delete']).to eq('#/components/schemas/adjustment_nested_delete_payload')
    end
  end

  describe 'Enum filter unions' do
    it 'generates oneOf for enum filter with direct value and operators' do
      filter = spec[:components][:schemas]['invoice_status_filter']

      expect(filter[:oneOf].length).to eq(2)
    end

    it 'includes enum values in direct value variant' do
      filter = spec[:components][:schemas]['invoice_status_filter']
      direct_variant = filter[:oneOf].find { |variant| variant[:enum] }

      expect(direct_variant[:enum]).to eq(%w[draft sent paid overdue void])
      expect(direct_variant[:type]).to eq('string')
    end

    it 'includes operators in object variant' do
      filter = spec[:components][:schemas]['invoice_status_filter']
      object_variant = filter[:oneOf].find { |variant| variant[:type] == 'object' }

      expect(object_variant[:properties]).to have_key('eq')
      expect(object_variant[:properties]).to have_key('in')
    end
  end
end
