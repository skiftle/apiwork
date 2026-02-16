# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Object, '#validate datetime and date types' do
  let(:contract_class) { create_test_contract }
  let(:definition) { described_class.new(contract_class) }

  describe 'datetime type validation' do
    before do
      definition.datetime :archived_at
    end

    context 'with valid datetime values' do
      it 'accepts Time object' do
        time = Time.zone.parse('2024-01-15T10:30:00Z')
        result = definition.validate({ archived_at: time })

        expect(result.issues).to be_empty
        expect(result.issues).to be_empty
        expect(result.params[:archived_at]).to eq(time)
      end

      it 'accepts DateTime object' do
        datetime = DateTime.parse('2024-01-15T10:30:00Z')
        result = definition.validate({ archived_at: datetime })

        expect(result.issues).to be_empty
        expect(result.issues).to be_empty
      end

      it 'accepts ActiveSupport::TimeWithZone object' do
        time_with_zone = ActiveSupport::TimeZone['UTC'].parse('2024-01-15T10:30:00')
        result = definition.validate({ archived_at: time_with_zone })

        expect(result.issues).to be_empty
        expect(result.issues).to be_empty
      end

      it 'preserves Time object type and value' do
        time = Time.zone.parse('2024-01-15T10:30:00Z')
        result = definition.validate({ archived_at: time })

        expect(result.issues).to be_empty
        expect(result.params[:archived_at]).to be_a(Time)
        expect(result.params[:archived_at]).to eq(time)
      end

      it 'rejects string without coercion' do
        result = definition.validate({ archived_at: '2024-01-15 10:30:00' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'with invalid datetime values' do
      it 'rejects string' do
        result = definition.validate({ archived_at: '2024-13-45' })

        expect(result.issues).not_to be_empty
        expect(result.issues.length).to eq(1)
        expect(result.issues.first.code).to eq(:type_invalid)
        expect(result.issues.first.meta[:expected]).to eq(:datetime)
        expect(result.issues.first.meta[:actual]).to eq(:string)
      end

      it 'rejects non-date string' do
        result = definition.validate({ archived_at: 'not-a-date' })

        expect(result.issues).not_to be_empty
        expect(result.issues.length).to eq(1)
        expect(result.issues.first.code).to eq(:type_invalid)
      end

      it 'rejects invalid date string' do
        result = definition.validate({ archived_at: '2024-01-32' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
      end

      it 'rejects empty string' do
        result = definition.validate({ archived_at: '' })

        expect(result.issues).not_to be_empty
        # Empty string is caught by required validation
        expect(result.issues.first.code).to eq(:field_missing)
      end

      it 'rejects Integer type' do
        result = definition.validate({ archived_at: 42 })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
        expect(result.issues.first.meta[:expected]).to eq(:datetime)
        expect(result.issues.first.meta[:actual]).to eq(:integer)
      end

      it 'rejects Boolean type' do
        result = definition.validate({ archived_at: true })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'when datetime field is optional and nullable' do
      before do
        definition.instance_variable_set(:@params, {})
        definition.datetime :archived_at, nullable: true, optional: true
      end

      it 'allows nil value' do
        result = definition.validate({ archived_at: nil })

        expect(result.issues).to be_empty
        expect(result.params).to eq({})
      end

      it 'allows missing field' do
        result = definition.validate({})

        expect(result.issues).to be_empty
      end
    end
  end

  describe 'date type validation' do
    before do
      definition.date :birth_date
    end

    context 'with valid date values' do
      it 'accepts Date object' do
        date = Date.parse('2024-01-15')
        result = definition.validate({ birth_date: date })

        expect(result.issues).to be_empty
        expect(result.issues).to be_empty
        expect(result.params[:birth_date]).to eq(date)
      end

      it 'rejects string without coercion' do
        result = definition.validate({ birth_date: '2024-01-15' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
        expect(result.issues.first.meta[:expected]).to eq(:date)
        expect(result.issues.first.meta[:actual]).to eq(:string)
      end
    end

    context 'with invalid date values' do
      it 'rejects invalid date string (Feb 30)' do
        result = definition.validate({ birth_date: '2024-02-30' })

        expect(result.issues).not_to be_empty
        expect(result.issues.length).to eq(1)
        expect(result.issues.first.code).to eq(:type_invalid)
        expect(result.issues.first.meta[:expected]).to eq(:date)
        expect(result.issues.first.meta[:actual]).to eq(:string)
      end

      it 'rejects non-date string' do
        result = definition.validate({ birth_date: 'not-a-date' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
      end

      it 'rejects invalid month string' do
        result = definition.validate({ birth_date: '2024-13-01' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
      end

      it 'rejects empty string' do
        result = definition.validate({ birth_date: '' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:field_missing)
      end

      it 'rejects Integer type' do
        result = definition.validate({ birth_date: 20_240_115 })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
        expect(result.issues.first.meta[:expected]).to eq(:date)
        expect(result.issues.first.meta[:actual]).to eq(:integer)
      end

      it 'rejects Time object' do
        result = definition.validate({ birth_date: Time.zone.now })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:type_invalid)
      end
    end

    context 'when date field is optional and nullable' do
      before do
        definition.instance_variable_set(:@params, {})
        definition.date :birth_date, nullable: true, optional: true
      end

      it 'allows nil value' do
        result = definition.validate({ birth_date: nil })

        expect(result.issues).to be_empty
        expect(result.params).to eq({})
      end

      it 'allows missing field' do
        result = definition.validate({})

        expect(result.issues).to be_empty
      end
    end
  end

  describe 'required enum validation' do
    before do
      definition.string :status, enum: %w[active inactive archived]
    end

    context 'when required enum field is missing' do
      it 'returns value_invalid error with allowed values' do
        result = definition.validate({})

        expect(result.issues).not_to be_empty
        expect(result.issues.length).to eq(1)

        error = result.issues.first
        expect(error.code).to eq(:value_invalid)
        expect(error.meta[:field]).to eq(:status)
        expect(error.detail).to eq('Invalid value')
        expect(error.meta[:expected]).to eq(%w[active inactive archived])
        expect(error.meta[:actual]).to be_nil
      end
    end

    context 'when required enum field is nil' do
      it 'returns value_invalid error with allowed values' do
        result = definition.validate({ status: nil })

        expect(result.issues).not_to be_empty

        error = result.issues.first
        expect(error.code).to eq(:value_invalid)
        expect(error.meta[:field]).to eq(:status)
        expect(error.detail).to eq('Invalid value')
        expect(error.meta[:expected]).to eq(%w[active inactive archived])
        expect(error.meta[:actual]).to be_nil
      end
    end

    context 'when required enum field is empty string' do
      it 'returns value_invalid error with allowed values' do
        result = definition.validate({ status: '' })

        expect(result.issues).not_to be_empty

        error = result.issues.first
        expect(error.code).to eq(:value_invalid)
        expect(error.meta[:field]).to eq(:status)
        expect(error.detail).to eq('Invalid value')
        expect(error.meta[:expected]).to eq(%w[active inactive archived])
        expect(error.meta[:actual]).to eq('')
      end
    end

    context 'when required enum field has invalid value' do
      it 'returns value_invalid error' do
        result = definition.validate({ status: 'deleted' })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:value_invalid)
        expect(result.issues.first.meta[:field]).to eq(:status)
        expect(result.issues.first.meta[:expected]).to eq(%w[active inactive archived])
        expect(result.issues.first.meta[:actual]).to eq('deleted')
      end
    end

    context 'when required enum field has valid value' do
      it 'accepts the value' do
        result = definition.validate({ status: 'active' })

        expect(result.issues).to be_empty
        expect(result.params[:status]).to eq('active')
      end
    end

    context 'error message includes field name and allowed values' do
      it 'provides helpful error detail via meta' do
        result = definition.validate({ status: 'deleted' })

        error = result.issues.first
        expect(error.detail).to eq('Invalid value')
        expect(error.meta[:expected]).to include('active', 'inactive', 'archived')
      end
    end
  end

  describe 'optional and nullable enum validation' do
    before do
      definition.string :status, enum: %w[active inactive], nullable: true, optional: true
    end

    it 'allows missing field' do
      result = definition.validate({})

      expect(result.issues).to be_empty
      expect(result.params).to eq({})
    end

    it 'allows nil value' do
      result = definition.validate({ status: nil })

      expect(result.issues).to be_empty
      expect(result.params).to eq({})
    end

    it 'rejects invalid enum value' do
      result = definition.validate({ status: 'deleted' })

      expect(result.issues).not_to be_empty
      expect(result.issues.first.code).to eq(:value_invalid)
    end

    it 'accepts valid enum value' do
      result = definition.validate({ status: 'active' })

      expect(result.issues).to be_empty
      expect(result.params[:status]).to eq('active')
    end
  end

  describe 'required non-enum fields' do
    let(:definition) do
      described_class.new(contract_class).tap do |d|
        d.string :name
      end
    end

    context 'when non-enum required field is missing' do
      it 'returns field_missing error' do
        result = definition.validate({})

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:field_missing)
        expect(error.detail).to eq('Required')
        expect(error.meta[:field]).to eq(:name)
      end
    end

    context 'when non-enum required field is nil' do
      it 'returns field_missing error' do
        result = definition.validate({ name: nil })

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:field_missing)
        expect(error.detail).to eq('Required')
      end
    end

    context 'when non-enum required field is empty string' do
      it 'accepts empty string as valid string value' do
        result = definition.validate({ name: '' })

        expect(result.issues).to be_empty
      end
    end
  end

  describe 'nullable validation for associations' do
    let(:definition) do
      described_class.new(contract_class).tap do |d|
        d.object :address, nullable: false, optional: true
      end
    end

    context 'when nullable: false' do
      it 'rejects nil value' do
        result = definition.validate({ address: nil })

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:value_null)
        expect(error.meta[:field]).to eq(:address)
        expect(error.detail).to eq('Cannot be null')
      end

      it 'accepts non-nil object value' do
        result = definition.validate({ address: { street: '123 Main St' } })

        expect(result.issues).to be_empty
        expect(result.params[:address]).to eq({ street: '123 Main St' })
      end

      it 'allows missing field when not required' do
        result = definition.validate({})

        expect(result.issues).to be_empty
        expect(result.params).to eq({})
      end
    end

    context 'when nullable: true' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.object :address, nullable: true, optional: true
        end
      end

      it 'accepts nil value' do
        result = definition.validate({ address: nil })

        expect(result.issues).to be_empty
        expect(result.params).to eq({})
      end

      it 'accepts non-nil object value' do
        result = definition.validate({ address: { street: '123 Main St' } })

        expect(result.issues).to be_empty
        expect(result.params[:address]).to eq({ street: '123 Main St' })
      end

      it 'allows missing field when not required' do
        result = definition.validate({})

        expect(result.issues).to be_empty
        expect(result.params).to eq({})
      end
    end

    context 'when nullable: true is specified' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.object :address, nullable: true, optional: true
        end
      end

      it 'accepts nil value when nullable: true' do
        result = definition.validate({ address: nil })

        expect(result.issues).to be_empty
        expect(result.params).to eq({})
      end
    end

    context 'with array type (has_many)' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.param :comments, nullable: false, optional: true, type: :array
        end
      end

      it 'rejects nil value when nullable: false' do
        result = definition.validate({ comments: nil })

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:value_null)
        expect(error.meta[:field]).to eq(:comments)
      end

      it 'accepts empty array' do
        result = definition.validate({ comments: [] })

        expect(result.issues).to be_empty
        expect(result.params[:comments]).to eq([])
      end

      it 'accepts non-empty array' do
        result = definition.validate({ comments: [{ content: 'Great!' }] })

        expect(result.issues).to be_empty
        expect(result.params[:comments]).to eq([{ content: 'Great!' }])
      end
    end
  end

  describe 'array length validation with max and min' do
    context 'with max constraint' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.param :tags, max: 3, of: :string, optional: true, type: :array
        end
      end

      it 'accepts array within max limit' do
        result = definition.validate({ tags: %w[ruby rails api] })

        expect(result.issues).to be_empty
        expect(result.params[:tags]).to eq(%w[ruby rails api])
      end

      it 'accepts array at exactly max limit' do
        result = definition.validate({ tags: %w[a b c] })

        expect(result.issues).to be_empty
        expect(result.params[:tags]).to eq(%w[a b c])
      end

      it 'rejects array exceeding max limit' do
        result = definition.validate({ tags: %w[a b c d] })

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:array_too_large)
        expect(error.detail).to eq('Too many items')
        expect(error.meta[:max]).to eq(3)
        expect(error.meta[:actual]).to eq(4)
      end

      it 'accepts empty array' do
        result = definition.validate({ tags: [] })

        expect(result.issues).to be_empty
        expect(result.params[:tags]).to eq([])
      end
    end

    context 'with min constraint' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.param :tags, min: 2, of: :string, optional: true, type: :array
        end
      end

      it 'accepts array above min limit' do
        result = definition.validate({ tags: %w[ruby rails api] })

        expect(result.issues).to be_empty
        expect(result.params[:tags]).to eq(%w[ruby rails api])
      end

      it 'accepts array at exactly min limit' do
        result = definition.validate({ tags: %w[a b] })

        expect(result.issues).to be_empty
        expect(result.params[:tags]).to eq(%w[a b])
      end

      it 'rejects array below min limit' do
        result = definition.validate({ tags: %w[only_one] })

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:array_too_small)
        expect(error.detail).to eq('Too few items')
        expect(error.meta[:min]).to eq(2)
        expect(error.meta[:actual]).to eq(1)
      end

      it 'rejects empty array when min is set' do
        result = definition.validate({ tags: [] })

        expect(result.issues).not_to be_empty
        error = result.issues.first
        expect(error.code).to eq(:array_too_small)
        expect(error.meta[:min]).to eq(2)
        expect(error.meta[:actual]).to eq(0)
      end
    end

    context 'with both min and max constraints' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.param :tags, max: 5, min: 1, of: :string, optional: true, type: :array
        end
      end

      it 'accepts array within range' do
        result = definition.validate({ tags: %w[a b c] })

        expect(result.issues).to be_empty
        expect(result.params[:tags]).to eq(%w[a b c])
      end

      it 'accepts array at min boundary' do
        result = definition.validate({ tags: %w[single] })

        expect(result.issues).to be_empty
      end

      it 'accepts array at max boundary' do
        result = definition.validate({ tags: %w[a b c d e] })

        expect(result.issues).to be_empty
      end

      it 'rejects array below min' do
        result = definition.validate({ tags: [] })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:array_too_small)
      end

      it 'rejects array above max' do
        result = definition.validate({ tags: %w[a b c d e f] })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:array_too_large)
      end
    end

    context 'without length constraints' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.param :tags, of: :string, optional: true, type: :array
        end
      end

      it 'accepts empty array' do
        result = definition.validate({ tags: [] })

        expect(result.issues).to be_empty
      end

      it 'accepts large array' do
        large_array = (1..100).map(&:to_s)
        result = definition.validate({ tags: large_array })

        expect(result.issues).to be_empty
        expect(result.params[:tags].length).to eq(100)
      end
    end

    context 'with nested object arrays' do
      let(:definition) do
        described_class.new(contract_class).tap do |d|
          d.param :comments, max: 10, min: 1, of: :object, optional: true, type: :array
        end
      end

      it 'validates length for object arrays' do
        result = definition.validate({ comments: [{ text: 'hello' }, { text: 'world' }] })

        expect(result.issues).to be_empty
        expect(result.params[:comments].length).to eq(2)
      end

      it 'rejects object array exceeding max' do
        comments = (1..11).map { |i| { text: "comment #{i}" } }
        result = definition.validate({ comments: })

        expect(result.issues).not_to be_empty
        expect(result.issues.first.code).to eq(:array_too_large)
      end
    end
  end
end
