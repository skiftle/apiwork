# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Security and edge case validation' do
  let(:contract_class) { create_test_contract }

  describe 'large array handling' do
    let(:definition) do
      Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :items, type: :array, of: :integer, optional: true
      end
    end

    it 'handles array with 1000 elements' do
      large_array = (1..1000).to_a
      result = definition.validate({ items: large_array })

      expect(result[:issues]).to be_empty
      expect(result[:params][:items].size).to eq(1000)
    end

    it 'validates all elements in large array' do
      large_array = Array.new(100, 42)
      result = definition.validate({ items: large_array })

      expect(result[:issues]).to be_empty
    end
  end

  describe 'malformed input handling' do
    let(:definition) do
      Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :name, type: :string
      end
    end

    it 'handles empty hash when required field missing' do
      result = definition.validate({})

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:field_missing)
      expect(result[:issues].first.path).to eq([:name])
    end
  end

  describe 'special character handling' do
    let(:definition) do
      Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :text, type: :string, optional: true
      end
    end

    it 'handles unicode characters' do
      result = definition.validate({ text: '你好世界 🌍 Здравствуй мир' })

      expect(result[:issues]).to be_empty
      expect(result[:params][:text]).to eq('你好世界 🌍 Здравствуй мир')
    end

    it 'handles very long strings' do
      long_string = 'a' * 100_000
      result = definition.validate({ text: long_string })

      expect(result[:issues]).to be_empty
      expect(result[:params][:text].length).to eq(100_000)
    end

    it 'handles string with max_length constraint' do
      constrained_def = Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :text, type: :string, optional: true, max: 100
      end

      result = constrained_def.validate({ text: 'a' * 101 })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:string_too_long)
    end
  end

  describe 'type confusion protection' do
    let(:definition) do
      Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :count, type: :integer, optional: true
        d.param :active, type: :boolean, optional: true
      end
    end

    it 'rejects object when integer expected' do
      result = definition.validate({ count: { nested: 'value' } })

      expect(result[:issues]).not_to be_empty
      issue = result[:issues].first
      expect(issue.path).to eq([:count])
      expect(issue.code).to eq(:type_invalid)
    end

    it 'rejects array when boolean expected' do
      result = definition.validate({ active: [true, false] })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].first.code).to eq(:type_invalid)
    end
  end

  describe 'boundary value validation' do
    let(:definition) do
      Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :huge_int, type: :integer, optional: true
        d.param :precise_float, type: :float, optional: true
      end
    end

    it 'handles very large integers' do
      result = definition.validate({ huge_int: 9_999_999_999_999_999_999 })

      expect(result[:issues]).to be_empty
      expect(result[:params][:huge_int]).to eq(9_999_999_999_999_999_999)
    end

    it 'handles very small floats' do
      result = definition.validate({ precise_float: 0.000000000001 })

      expect(result[:issues]).to be_empty
      expect(result[:params][:precise_float]).to be_within(0.000000000001).of(0.000000000001)
    end
  end

  describe 'error accumulation' do
    it 'reports multiple validation errors' do
      multi_def = Apiwork::Contract::Definition.new(type: :input, contract_class: contract_class).tap do |d|
        d.param :field1, type: :integer
        d.param :field2, type: :integer
        d.param :field3, type: :integer
      end

      result = multi_def.validate({
                                    field1: 'invalid',
                                    field2: 'invalid',
                                    field3: 'invalid'
                                  })

      expect(result[:issues]).not_to be_empty
      expect(result[:issues].size).to eq(3)
    end
  end
end
