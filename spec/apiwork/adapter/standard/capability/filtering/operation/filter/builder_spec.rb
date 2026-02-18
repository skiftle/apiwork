# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Standard::Capability::Filtering::Operation::Filter::Builder do
  let(:column) { Arel::Table.new(:invoices)[:status] }
  let(:field_name) { :status }
  let(:allowed_types) { [String, Hash] }
  let(:valid_operators) { %i[eq in] }
  let(:builder) { described_class.new(column, field_name, allowed_types:) }

  describe '#initialize' do
    it 'stores column' do
      expect(builder.column).to eq(column)
    end

    it 'stores field_name' do
      expect(builder.field_name).to eq(:status)
    end

    it 'stores allowed_types as array' do
      expect(builder.allowed_types).to eq([String, Hash])
    end

    context 'when allowed_types is a single class' do
      let(:allowed_types) { String }

      it 'wraps in array' do
        expect(builder.allowed_types).to eq([String])
      end
    end
  end

  describe '#build' do
    context 'when value type is allowed' do
      it 'delegates to OperatorBuilder' do
        result = builder.build({ eq: 'draft' }, valid_operators:) do |operator, value|
          "#{operator}:#{value}"
        end

        expect(result).to eq('eq:draft')
      end
    end

    context 'when value type is not allowed' do
      let(:allowed_types) { [String] }

      it 'returns nil for Integer' do
        result = builder.build({ eq: 123 }, valid_operators:) do |operator, value|
          "#{operator}:#{value}"
        end

        expect(result).to be_nil
      end

      it 'returns nil for Array' do
        result = builder.build({ in: %w[a b] }, valid_operators:) do |operator, value|
          "#{operator}:#{value}"
        end

        expect(result).to be_nil
      end
    end

    context 'when allowed_types is empty' do
      let(:allowed_types) { [] }

      it 'accepts any value type' do
        result = builder.build({ eq: 123 }, valid_operators:) do |operator, value|
          "#{operator}:#{value}"
        end

        expect(result).to eq('eq:123')
      end
    end

    context 'with normalizer' do
      it 'applies normalizer before type validation' do
        normalizer = ->(v) { v.transform_values(&:upcase) }

        result = builder.build({ eq: 'draft' }, normalizer:, valid_operators:) do |_operator, value|
          column.eq(value)
        end

        expect(result).to eq(column.eq('DRAFT'))
      end

      it 'normalizes before type check' do
        normalizer = ->(v) { { eq: v.to_s } }
        single_type_builder = described_class.new(column, field_name, allowed_types: [Hash])

        result = single_type_builder.build(123, normalizer:, valid_operators:) do |_operator, value|
          column.eq(value)
        end

        expect(result).to eq(column.eq('123'))
      end
    end

    context 'without normalizer' do
      it 'uses value as-is' do
        result = builder.build({ eq: 'draft' }, valid_operators:) do |operator, value|
          "#{operator}:#{value}"
        end

        expect(result).to eq('eq:draft')
      end
    end

    context 'with multiple operators' do
      it 'combines conditions with AND' do
        result = builder.build({ eq: 'draft', in: %w[a b] }, valid_operators:) do |operator, value|
          if operator == :eq
            column.eq(value)
          else
            column.in(value)
          end
        end

        expect(result).to eq(column.eq('draft').and(column.in(%w[a b])))
      end
    end
  end
end
