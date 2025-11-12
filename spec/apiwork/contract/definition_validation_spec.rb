# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::Definition, '#validate datetime and date types' do
  let(:contract_class) { Class.new(Apiwork::Contract::Base) }
  let(:definition) { described_class.new(:input, contract_class) }

  describe 'datetime type validation' do
    before do
      definition.param :archived_at, type: :datetime, required: true
    end

    context 'with valid datetime values' do
      it 'accepts Time object' do
        time = Time.zone.parse('2024-01-15T10:30:00Z')
        result = definition.validate({ archived_at: time })

        expect(result[:errors]).to be_empty
        expect(result[:errors]).to be_empty
        expect(result[:params][:archived_at]).to eq(time)
      end

      it 'accepts DateTime object' do
        datetime = DateTime.parse('2024-01-15T10:30:00Z')
        result = definition.validate({ archived_at: datetime })

        expect(result[:errors]).to be_empty
        expect(result[:errors]).to be_empty
      end

      it 'accepts ActiveSupport::TimeWithZone object' do
        time_with_zone = ActiveSupport::TimeZone['UTC'].parse('2024-01-15T10:30:00')
        result = definition.validate({ archived_at: time_with_zone })

        expect(result[:errors]).to be_empty
        expect(result[:errors]).to be_empty
      end

      it 'accepts Time object' do
        time = Time.zone.parse('2024-01-15T10:30:00Z')
        result = definition.validate({ archived_at: time })

        expect(result[:errors]).to be_empty
        expect(result[:params][:archived_at]).to be_a(Time)
        expect(result[:params][:archived_at]).to eq(time)
      end

      it 'rejects string without coercion' do
        result = definition.validate({ archived_at: '2024-01-15 10:30:00' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
      end
    end

    context 'with invalid datetime values' do
      it 'rejects string' do
        result = definition.validate({ archived_at: '2024-13-45' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].length).to eq(1)
        expect(result[:errors].first.code).to eq(:invalid_type)
        expect(result[:errors].first.meta[:expected]).to eq(:datetime)
        expect(result[:errors].first.meta[:actual]).to eq(:string)
      end

      it 'rejects string' do
        result = definition.validate({ archived_at: 'not-a-date' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].length).to eq(1)
        expect(result[:errors].first.code).to eq(:invalid_type)
      end

      it 'rejects string' do
        result = definition.validate({ archived_at: '2024-01-32' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
      end

      it 'rejects empty string' do
        result = definition.validate({ archived_at: '' })

        expect(result[:errors]).not_to be_empty
        # Empty string is caught by required validation
        expect(result[:errors].first.code).to eq(:field_missing)
      end

      it 'rejects Integer type' do
        result = definition.validate({ archived_at: 42 })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
        expect(result[:errors].first.meta[:expected]).to eq(:datetime)
        expect(result[:errors].first.meta[:actual]).to eq(:integer)
      end

      it 'rejects Boolean type' do
        result = definition.validate({ archived_at: true })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
      end
    end

    context 'when datetime field is optional' do
      before do
        definition.instance_variable_set(:@params, {})
        definition.param :archived_at, type: :datetime, required: false
      end

      it 'allows nil value' do
        result = definition.validate({ archived_at: nil })

        expect(result[:errors]).to be_empty
        expect(result[:params]).to eq({})
      end

      it 'allows missing field' do
        result = definition.validate({})

        expect(result[:errors]).to be_empty
      end
    end
  end

  describe 'date type validation' do
    before do
      definition.param :birth_date, type: :date, required: true
    end

    context 'with valid date values' do
      it 'accepts Date object' do
        date = Date.parse('2024-01-15')
        result = definition.validate({ birth_date: date })

        expect(result[:errors]).to be_empty
        expect(result[:errors]).to be_empty
        expect(result[:params][:birth_date]).to eq(date)
      end

      it 'rejects string without coercion' do
        result = definition.validate({ birth_date: '2024-01-15' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
        expect(result[:errors].first.meta[:expected]).to eq(:date)
        expect(result[:errors].first.meta[:actual]).to eq(:string)
      end
    end

    context 'with invalid date values' do
      it 'rejects string' do
        result = definition.validate({ birth_date: '2024-02-30' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].length).to eq(1)
        expect(result[:errors].first.code).to eq(:invalid_type)
        expect(result[:errors].first.meta[:expected]).to eq(:date)
        expect(result[:errors].first.meta[:actual]).to eq(:string)
      end

      it 'rejects string' do
        result = definition.validate({ birth_date: 'not-a-date' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
      end

      it 'rejects string' do
        result = definition.validate({ birth_date: '2024-13-01' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
      end

      it 'rejects empty string' do
        result = definition.validate({ birth_date: '' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:field_missing)
      end

      it 'rejects Integer type' do
        result = definition.validate({ birth_date: 20_240_115 })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
        expect(result[:errors].first.meta[:expected]).to eq(:date)
        expect(result[:errors].first.meta[:actual]).to eq(:integer)
      end

      it 'rejects Time object' do
        result = definition.validate({ birth_date: Time.zone.now })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_type)
      end
    end

    context 'when date field is optional' do
      before do
        definition.instance_variable_set(:@params, {})
        definition.param :birth_date, type: :date, required: false
      end

      it 'allows nil value' do
        result = definition.validate({ birth_date: nil })

        expect(result[:errors]).to be_empty
        expect(result[:params]).to eq({})
      end

      it 'allows missing field' do
        result = definition.validate({})

        expect(result[:errors]).to be_empty
      end
    end
  end

  describe 'required enum validation' do
    before do
      definition.param :status, type: :string, enum: %w[active inactive archived], required: true
    end

    context 'when required enum field is missing' do
      it 'returns invalid_value error with allowed values' do
        result = definition.validate({})

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].length).to eq(1)

        error = result[:errors].first
        expect(error.code).to eq(:invalid_value)
        expect(error.field).to eq(:status)
        expect(error.detail).to include('active', 'inactive', 'archived')
        expect(error.meta[:expected]).to eq(%w[active inactive archived])
        expect(error.meta[:actual]).to be_nil
      end
    end

    context 'when required enum field is nil' do
      it 'returns invalid_value error with allowed values' do
        result = definition.validate({ status: nil })

        expect(result[:errors]).not_to be_empty

        error = result[:errors].first
        expect(error.code).to eq(:invalid_value)
        expect(error.field).to eq(:status)
        expect(error.detail).to include('active', 'inactive', 'archived')
        expect(error.meta[:expected]).to eq(%w[active inactive archived])
        expect(error.meta[:actual]).to be_nil
      end
    end

    context 'when required enum field is empty string' do
      it 'returns invalid_value error with allowed values' do
        result = definition.validate({ status: '' })

        expect(result[:errors]).not_to be_empty

        error = result[:errors].first
        expect(error.code).to eq(:invalid_value)
        expect(error.field).to eq(:status)
        expect(error.detail).to include('active', 'inactive', 'archived')
        expect(error.meta[:expected]).to eq(%w[active inactive archived])
        expect(error.meta[:actual]).to eq('')
      end
    end

    context 'when required enum field has invalid value' do
      it 'returns invalid_value error' do
        result = definition.validate({ status: 'deleted' })

        expect(result[:errors]).not_to be_empty
        expect(result[:errors].first.code).to eq(:invalid_value)
        expect(result[:errors].first.field).to eq(:status)
        expect(result[:errors].first.meta[:expected]).to eq(%w[active inactive archived])
        expect(result[:errors].first.meta[:actual]).to eq('deleted')
      end
    end

    context 'when required enum field has valid value' do
      it 'accepts the value' do
        result = definition.validate({ status: 'active' })

        expect(result[:errors]).to be_empty
        expect(result[:params][:status]).to eq('active')
      end
    end

    context 'error message includes field name and allowed values' do
      it 'provides helpful error detail' do
        result = definition.validate({ status: 'deleted' })

        error = result[:errors].first
        expect(error.detail).to include('active')
        expect(error.detail).to include('inactive')
        expect(error.detail).to include('archived')
      end
    end
  end

  describe 'optional enum validation' do
    before do
      definition.param :status, type: :string, enum: %w[active inactive], required: false
    end

    it 'allows missing field' do
      result = definition.validate({})

      expect(result[:errors]).to be_empty
      expect(result[:params]).to eq({})
    end

    it 'allows nil value' do
      result = definition.validate({ status: nil })

      expect(result[:errors]).to be_empty
      expect(result[:params]).to eq({})
    end

    it 'rejects invalid enum value' do
      result = definition.validate({ status: 'deleted' })

      expect(result[:errors]).not_to be_empty
      expect(result[:errors].first.code).to eq(:invalid_value)
    end

    it 'accepts valid enum value' do
      result = definition.validate({ status: 'active' })

      expect(result[:errors]).to be_empty
      expect(result[:params][:status]).to eq('active')
    end
  end

  describe 'required non-enum fields' do
    let(:definition) do
      described_class.new(:input, contract_class).tap do |d|
        d.param :name, type: :string, required: true
      end
    end

    context 'when non-enum required field is missing' do
      it 'returns field_missing error' do
        result = definition.validate({})

        expect(result[:errors]).not_to be_empty
        error = result[:errors].first
        expect(error.code).to eq(:field_missing)
        expect(error.detail).to eq('Field required')
        expect(error.field).to eq(:name)
      end
    end

    context 'when non-enum required field is nil' do
      it 'returns field_missing error' do
        result = definition.validate({ name: nil })

        expect(result[:errors]).not_to be_empty
        error = result[:errors].first
        expect(error.code).to eq(:field_missing)
        expect(error.detail).to eq('Field required')
      end
    end

    context 'when non-enum required field is empty string' do
      it 'returns field_missing error' do
        result = definition.validate({ name: '' })

        expect(result[:errors]).not_to be_empty
        error = result[:errors].first
        expect(error.code).to eq(:field_missing)
        expect(error.detail).to eq('Field required')
      end
    end
  end

  describe 'nullable validation for associations' do
    let(:definition) do
      described_class.new(:input, contract_class).tap do |d|
        d.param :address, type: :object, required: false, nullable: false
      end
    end

    context 'when nullable: false' do
      it 'rejects nil value' do
        result = definition.validate({ address: nil })

        expect(result[:errors]).not_to be_empty
        error = result[:errors].first
        expect(error.code).to eq(:value_null)
        expect(error.field).to eq(:address)
        expect(error.detail).to eq('Value cannot be null')
      end

      it 'accepts non-nil object value' do
        result = definition.validate({ address: { street: '123 Main St' } })

        expect(result[:errors]).to be_empty
        expect(result[:params][:address]).to eq({ street: '123 Main St' })
      end

      it 'allows missing field when not required' do
        result = definition.validate({})

        expect(result[:errors]).to be_empty
        expect(result[:params]).to eq({})
      end
    end

    context 'when nullable: true' do
      let(:definition) do
        described_class.new(:input, contract_class).tap do |d|
          d.param :address, type: :object, required: false, nullable: true
        end
      end

      it 'accepts nil value' do
        result = definition.validate({ address: nil })

        expect(result[:errors]).to be_empty
        expect(result[:params]).to eq({})
      end

      it 'accepts non-nil object value' do
        result = definition.validate({ address: { street: '123 Main St' } })

        expect(result[:errors]).to be_empty
        expect(result[:params][:address]).to eq({ street: '123 Main St' })
      end

      it 'allows missing field when not required' do
        result = definition.validate({})

        expect(result[:errors]).to be_empty
        expect(result[:params]).to eq({})
      end
    end

    context 'when nullable is not specified (defaults to allowing nil)' do
      let(:definition) do
        described_class.new(:input, contract_class).tap do |d|
          d.param :address, type: :object, required: false
        end
      end

      it 'accepts nil value when nullable not specified' do
        result = definition.validate({ address: nil })

        expect(result[:errors]).to be_empty
        expect(result[:params]).to eq({})
      end
    end

    context 'with array type (has_many)' do
      let(:definition) do
        described_class.new(:input, contract_class).tap do |d|
          d.param :comments, type: :array, required: false, nullable: false
        end
      end

      it 'rejects nil value when nullable: false' do
        result = definition.validate({ comments: nil })

        expect(result[:errors]).not_to be_empty
        error = result[:errors].first
        expect(error.code).to eq(:value_null)
        expect(error.field).to eq(:comments)
      end

      it 'accepts empty array' do
        result = definition.validate({ comments: [] })

        expect(result[:errors]).to be_empty
        expect(result[:params][:comments]).to eq([])
      end

      it 'accepts non-empty array' do
        result = definition.validate({ comments: [{ content: 'Great!' }] })

        expect(result[:errors]).to be_empty
        expect(result[:params][:comments]).to eq([{ content: 'Great!' }])
      end
    end
  end
end
