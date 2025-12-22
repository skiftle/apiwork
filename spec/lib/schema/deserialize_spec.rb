# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schema.deserialize' do
  let(:schema_class) do
    Class.new(Apiwork::Schema::Base) do
      abstract!

      attribute :title, type: :string
      attribute :email, type: :string, decode: ->(v) { v&.downcase&.strip }
      attribute :notes, type: :string, empty: true
      attribute :count, type: :integer
    end
  end

  describe '.deserialize' do
    it 'returns nil for nil input' do
      expect(schema_class.deserialize(nil)).to be_nil
    end

    it 'returns hash unchanged when no transformers defined' do
      result = schema_class.deserialize({ title: 'Hello', count: 42 })

      expect(result[:title]).to eq('Hello')
      expect(result[:count]).to eq(42)
    end

    it 'applies decode transformer to attribute' do
      result = schema_class.deserialize({ email: '  USER@EXAMPLE.COM  ' })

      expect(result[:email]).to eq('user@example.com')
    end

    it 'applies empty: true transformer (blank to nil)' do
      result = schema_class.deserialize({ notes: '' })

      expect(result[:notes]).to be_nil
    end

    it 'preserves non-empty values with empty: true' do
      result = schema_class.deserialize({ notes: 'Some notes' })

      expect(result[:notes]).to eq('Some notes')
    end

    it 'ignores keys not in attribute_definitions' do
      result = schema_class.deserialize({ title: 'Hello', unknown_key: 'ignored' })

      expect(result[:title]).to eq('Hello')
      expect(result[:unknown_key]).to eq('ignored')
    end

    it 'handles array input' do
      result = schema_class.deserialize([
                                          { email: 'ONE@EXAMPLE.COM' },
                                          { email: 'TWO@EXAMPLE.COM' }
                                        ])

      expect(result).to be_an(Array)
      expect(result[0][:email]).to eq('one@example.com')
      expect(result[1][:email]).to eq('two@example.com')
    end

    it 'handles empty array' do
      result = schema_class.deserialize([])

      expect(result).to eq([])
    end

    it 'returns non-hash values unchanged' do
      result = schema_class.deserialize('not a hash')

      expect(result).to eq('not a hash')
    end
  end

  describe '.deserialize_single' do
    it 'applies all decode transformers' do
      result = schema_class.deserialize_single({
                                                 title: 'Test',
                                                 email: '  UPPER@TEST.COM  ',
                                                 notes: ''
                                               })

      expect(result[:title]).to eq('Test')
      expect(result[:email]).to eq('upper@test.com')
      expect(result[:notes]).to be_nil
    end

    it 'does not modify original hash' do
      original = { email: '  UPPER@TEST.COM  ' }
      schema_class.deserialize_single(original)

      expect(original[:email]).to eq('  UPPER@TEST.COM  ')
    end
  end
end
