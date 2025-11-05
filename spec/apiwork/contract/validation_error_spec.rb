# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Contract::ValidationError do
  describe '.field_unknown' do
    it 'creates error with correct code' do
      error = described_class.field_unknown(
        field: :age,
        allowed: %i[name email],
        path: [:data]
      )

      expect(error.code).to eq(:field_unknown)
    end

    it 'includes field in error' do
      error = described_class.field_unknown(
        field: :age,
        allowed: %i[name email]
      )

      expect(error.field).to eq(:age)
    end

    it 'includes allowed fields in meta' do
      error = described_class.field_unknown(
        field: :age,
        allowed: %i[name email]
      )

      expect(error.meta[:allowed]).to eq(%i[name email])
    end

    it 'has short system-like detail message' do
      error = described_class.field_unknown(
        field: :age,
        allowed: %i[name email]
      )

      expect(error.detail).to eq('Unknown field')
    end

    it 'includes full path' do
      error = described_class.field_unknown(
        field: :age,
        allowed: %i[name email],
        path: %i[data attributes]
      )

      expect(error.path).to eq(%i[data attributes])
    end
  end

  describe '.field_missing' do
    it 'creates error with correct code' do
      error = described_class.field_missing(field: :name)

      expect(error.code).to eq(:field_missing)
    end

    it 'includes field in error' do
      error = described_class.field_missing(field: :name)

      expect(error.field).to eq(:name)
    end

    it 'has short system-like detail message' do
      error = described_class.field_missing(field: :name)

      expect(error.detail).to eq('Field required')
    end

    it 'includes path' do
      error = described_class.field_missing(field: :name, path: [:data])

      expect(error.path).to eq([:data])
    end
  end

  describe '.invalid_type' do
    it 'creates error with correct code' do
      error = described_class.invalid_type(
        field: :age,
        expected: :integer,
        actual: :string
      )

      expect(error.code).to eq(:invalid_type)
    end

    it 'includes expected type in meta' do
      error = described_class.invalid_type(
        field: :age,
        expected: :integer,
        actual: :string
      )

      expect(error.meta[:expected]).to eq(:integer)
    end

    it 'includes actual type in meta' do
      error = described_class.invalid_type(
        field: :age,
        expected: :integer,
        actual: :string
      )

      expect(error.meta[:actual]).to eq(:string)
    end

    it 'has short system-like detail message' do
      error = described_class.invalid_type(
        field: :age,
        expected: :integer,
        actual: :string
      )

      expect(error.detail).to eq('Invalid type')
    end
  end

  describe '.value_null' do
    it 'creates error with correct code' do
      error = described_class.value_null(field: :name)

      expect(error.code).to eq(:value_null)
    end

    it 'includes field in error' do
      error = described_class.value_null(field: :name)

      expect(error.field).to eq(:name)
    end

    it 'has short system-like detail message' do
      error = described_class.value_null(field: :name)

      expect(error.detail).to eq('Value cannot be null')
    end
  end

  describe '.max_depth_exceeded' do
    it 'creates error with correct code' do
      error = described_class.max_depth_exceeded(depth: 11, max_depth: 10)

      expect(error.code).to eq(:max_depth_exceeded)
    end

    it 'includes depth in meta' do
      error = described_class.max_depth_exceeded(depth: 11, max_depth: 10)

      expect(error.meta[:depth]).to eq(11)
    end

    it 'includes max_depth in meta' do
      error = described_class.max_depth_exceeded(depth: 11, max_depth: 10)

      expect(error.meta[:max_depth]).to eq(10)
    end

    it 'has short system-like detail message' do
      error = described_class.max_depth_exceeded(depth: 11, max_depth: 10)

      expect(error.detail).to eq('Max depth exceeded')
    end
  end

  describe '.array_too_large' do
    it 'creates error with correct code' do
      error = described_class.array_too_large(size: 1500, max_size: 1000)

      expect(error.code).to eq(:array_too_large)
    end

    it 'includes size in meta' do
      error = described_class.array_too_large(size: 1500, max_size: 1000)

      expect(error.meta[:size]).to eq(1500)
    end

    it 'includes max_size in meta' do
      error = described_class.array_too_large(size: 1500, max_size: 1000)

      expect(error.meta[:max_size]).to eq(1000)
    end

    it 'has short system-like detail message' do
      error = described_class.array_too_large(size: 1500, max_size: 1000)

      expect(error.detail).to eq('Value too large')
    end
  end

  describe '.coercion_failed' do
    it 'creates error with coercion_failed code' do
      error = described_class.coercion_failed(
        field: :archived_at,
        type: :datetime,
        value: '2024-13-45'
      )

      expect(error.code).to eq(:coercion_failed)
    end

    it 'includes expected type in meta' do
      error = described_class.coercion_failed(
        field: :archived_at,
        type: :datetime,
        value: '2024-13-45'
      )

      expect(error.meta[:expected_type]).to eq(:datetime)
    end

    it 'includes actual value in meta' do
      error = described_class.coercion_failed(
        field: :archived_at,
        type: :datetime,
        value: '2024-13-45'
      )

      expect(error.meta[:actual_value]).to eq('2024-13-45')
    end

    it 'has descriptive detail message' do
      error = described_class.coercion_failed(
        field: :archived_at,
        type: :datetime,
        value: '2024-13-45'
      )

      expect(error.detail).to eq('Could not parse value as datetime')
    end

    it 'truncates long values' do
      long_value = 'x' * 150
      error = described_class.coercion_failed(
        field: :data,
        type: :datetime,
        value: long_value
      )

      expect(error.meta[:actual_value].length).to be <= 103 # 100 chars + "..."
      expect(error.meta[:actual_value]).to end_with('...')
    end

    it 'includes path' do
      error = described_class.coercion_failed(
        field: :archived_at,
        type: :datetime,
        value: '2024-13-45',
        path: [:data, :attributes]
      )

      expect(error.path).to eq([:data, :attributes])
    end
  end

  describe '#to_h' do
    it 'converts error to hash with all fields' do
      error = described_class.invalid_type(
        field: :age,
        expected: :integer,
        actual: :string,
        path: %i[data attributes]
      )

      hash = error.to_h

      expect(hash).to include(
        code: :invalid_type,
        field: :age,
        detail: be_a(String),
        path: %w[data attributes],
        expected: :integer,
        actual: :string
      )
    end

    it 'converts path symbols to strings' do
      error = described_class.field_missing(
        field: :name,
        path: %i[data attributes]
      )

      hash = error.to_h

      expect(hash[:path]).to eq(%w[data attributes])
    end

    it 'includes expected_type and actual_value for coercion_failed' do
      error = described_class.coercion_failed(
        field: :archived_at,
        type: :datetime,
        value: '2024-13-45',
        path: [:data]
      )

      hash = error.to_h

      expect(hash).to include(
        code: :coercion_failed,
        field: :archived_at,
        detail: 'Could not parse value as datetime',
        path: ['data'],
        expected_type: :datetime,
        actual_value: '2024-13-45'
      )
    end
  end
end
