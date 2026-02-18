# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Standard::Capability::Filtering::Operation::Filter::OperatorBuilder do
  let(:column) { Arel::Table.new(:invoices)[:total] }
  let(:field_name) { :total }
  let(:valid_operators) { %i[eq gt lt] }
  let(:builder) { described_class.new(column, field_name, valid_operators:) }

  describe '#initialize' do
    it 'stores column' do
      expect(builder.column).to eq(column)
    end

    it 'stores field_name' do
      expect(builder.field_name).to eq(:total)
    end

    it 'stores valid_operators' do
      expect(builder.valid_operators).to eq(%i[eq gt lt])
    end
  end

  describe '#build' do
    context 'when operator is valid' do
      it 'yields operator and value to block' do
        yielded = []

        builder.build({ eq: 100 }) do |operator, value|
          yielded << [operator, value]
          'condition'
        end

        expect(yielded).to eq([[:eq, 100]])
      end

      it 'returns block result' do
        result = builder.build({ eq: 100 }) do |_operator, _value|
          'condition'
        end

        expect(result).to eq('condition')
      end
    end

    context 'when operator is invalid' do
      it 'skips invalid operators' do
        yielded = []

        builder.build({ ne: 100 }) do |operator, value|
          yielded << [operator, value]
          'condition'
        end

        expect(yielded).to be_empty
      end
    end

    context 'when all operators are invalid' do
      it 'returns nil' do
        result = builder.build({ between: [1, 100], ne: 100 }) do |_operator, _value|
          'condition'
        end

        expect(result).to be_nil
      end
    end

    context 'with single valid operator' do
      it 'returns single condition' do
        result = builder.build({ eq: 100 }) do |operator, value|
          "#{operator}=#{value}"
        end

        expect(result).to eq('eq=100')
      end
    end

    context 'with multiple valid operators' do
      it 'combines conditions with AND' do
        result = builder.build({ gt: 50, lt: 200 }) do |operator, value|
          if operator == :gt
            column.gt(value)
          else
            column.lt(value)
          end
        end

        expect(result).to eq(column.gt(50).and(column.lt(200)))
      end
    end

    context 'with mixed valid and invalid operators' do
      it 'only processes valid operators' do
        yielded = []

        builder.build({ eq: 100, gt: 25, ne: 50 }) do |operator, value|
          yielded << [operator, value]
          column.send(operator, value)
        end

        expect(yielded).to contain_exactly([:eq, 100], [:gt, 25])
      end
    end

    context 'when operator is string key' do
      it 'converts to symbol' do
        yielded = []

        builder.build({ 'eq' => 100 }) do |operator, value|
          yielded << [operator, value]
          'condition'
        end

        expect(yielded).to eq([[:eq, 100]])
      end
    end
  end
end
