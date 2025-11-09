# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Schema::Operators do
  describe 'BASE OPERATOR SETS' do
    it 'defines EQUALITY_OPERATORS' do
      expect(described_class::EQUALITY_OPERATORS).to eq(%i[eq neq])
    end

    it 'defines COMPARISON_OPERATORS' do
      expect(described_class::COMPARISON_OPERATORS).to eq(%i[
        gt
        gte
        lt
        lte
      ])
    end

    it 'defines RANGE_OPERATORS' do
      expect(described_class::RANGE_OPERATORS).to eq(%i[between nbetween])
    end

    it 'defines COLLECTION_OPERATORS' do
      expect(described_class::COLLECTION_OPERATORS).to eq(%i[in nin])
    end

    it 'defines STRING_SPECIFIC_OPERATORS' do
      expect(described_class::STRING_SPECIFIC_OPERATORS).to eq(%i[
        contains
        ncontains
        starts_with
        ends_with
      ])
    end
  end

  describe 'TYPE-SPECIFIC OPERATOR SETS' do
    describe 'STRING_OPERATORS' do
      it 'includes equality, collection, and string-specific operators' do
        expect(described_class::STRING_OPERATORS).to include(
          :eq, :neq,           # equality
          :in, :nin,                 # collection
          :contains, :starts_with       # string-specific
        )
      end

      it 'does not include comparison operators' do
        expect(described_class::STRING_OPERATORS).not_to include(:gt, :lt)
      end
    end

    describe 'DATE_OPERATORS' do
      it 'includes equality, comparison, range, and collection operators' do
        expect(described_class::DATE_OPERATORS).to include(
          :eq, :neq,                           # equality
          :gt, :lt,                    # comparison
          :between, :nbetween,                       # range
          :in, :nin                                  # collection
        )
      end

      it 'does not include string-specific operators' do
        expect(described_class::DATE_OPERATORS).not_to include(:contains, :starts_with)
      end
    end

    describe 'NUMERIC_OPERATORS' do
      it 'includes equality, comparison, range, and collection operators' do
        expect(described_class::NUMERIC_OPERATORS).to include(
          :eq, :neq,                           # equality
          :gt, :lt,                    # comparison
          :between, :nbetween,                       # range
          :in, :nin                                  # collection
        )
      end
    end

    describe 'UUID_OPERATORS' do
      it 'includes only equality and collection operators' do
        expect(described_class::UUID_OPERATORS).to eq(%i[
          eq neq
          in nin
        ])
      end

      it 'does not include comparison or range operators' do
        expect(described_class::UUID_OPERATORS).not_to include(:gt, :between)
      end
    end

    describe 'BOOLEAN_OPERATORS' do
      it 'includes only equality operators' do
        expect(described_class::BOOLEAN_OPERATORS).to eq(%i[eq neq])
      end
    end
  end

  describe 'OPERATORS_BY_TYPE' do
    it 'maps string type to STRING_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:string]).to eq(described_class::STRING_OPERATORS)
    end

    it 'maps text type to STRING_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:text]).to eq(described_class::STRING_OPERATORS)
    end

    it 'maps date type to DATE_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:date]).to eq(described_class::DATE_OPERATORS)
    end

    it 'maps datetime type to DATE_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:datetime]).to eq(described_class::DATE_OPERATORS)
    end

    it 'maps integer type to NUMERIC_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:integer]).to eq(described_class::NUMERIC_OPERATORS)
    end

    it 'maps float type to NUMERIC_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:float]).to eq(described_class::NUMERIC_OPERATORS)
    end

    it 'maps decimal type to NUMERIC_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:decimal]).to eq(described_class::NUMERIC_OPERATORS)
    end

    it 'maps uuid type to UUID_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:uuid]).to eq(described_class::UUID_OPERATORS)
    end

    it 'maps boolean type to BOOLEAN_OPERATORS' do
      expect(described_class::OPERATORS_BY_TYPE[:boolean]).to eq(described_class::BOOLEAN_OPERATORS)
    end
  end

  describe '.for_type' do
    it 'returns STRING_OPERATORS for :string type' do
      operators = described_class.for_type(:string)
      expect(operators).to eq(described_class::STRING_OPERATORS)
    end

    it 'returns STRING_OPERATORS for :text type' do
      operators = described_class.for_type(:text)
      expect(operators).to eq(described_class::STRING_OPERATORS)
    end

    it 'returns DATE_OPERATORS for :date type' do
      operators = described_class.for_type(:date)
      expect(operators).to eq(described_class::DATE_OPERATORS)
    end

    it 'returns DATE_OPERATORS for :datetime type' do
      operators = described_class.for_type(:datetime)
      expect(operators).to eq(described_class::DATE_OPERATORS)
    end

    it 'returns NUMERIC_OPERATORS for :integer type' do
      operators = described_class.for_type(:integer)
      expect(operators).to eq(described_class::NUMERIC_OPERATORS)
    end

    it 'returns NUMERIC_OPERATORS for :float type' do
      operators = described_class.for_type(:float)
      expect(operators).to eq(described_class::NUMERIC_OPERATORS)
    end

    it 'returns NUMERIC_OPERATORS for :decimal type' do
      operators = described_class.for_type(:decimal)
      expect(operators).to eq(described_class::NUMERIC_OPERATORS)
    end

    it 'returns UUID_OPERATORS for :uuid type' do
      operators = described_class.for_type(:uuid)
      expect(operators).to eq(described_class::UUID_OPERATORS)
    end

    it 'returns BOOLEAN_OPERATORS for :boolean type' do
      operators = described_class.for_type(:boolean)
      expect(operators).to eq(described_class::BOOLEAN_OPERATORS)
    end

    context 'with unknown type' do
      it 'returns EQUALITY_OPERATORS as default' do
        operators = described_class.for_type(:unknown_type)
        expect(operators).to eq(described_class::EQUALITY_OPERATORS)
      end
    end
  end

  describe 'operator composition' do
    it 'STRING_OPERATORS does not overlap with DATE_OPERATORS except for common operators' do
      string_only = described_class::STRING_OPERATORS - described_class::DATE_OPERATORS
      expect(string_only).to include(:contains, :starts_with, :ends_with)
    end

    it 'DATE_OPERATORS includes all comparison operators' do
      described_class::COMPARISON_OPERATORS.each do |op|
        expect(described_class::DATE_OPERATORS).to include(op)
      end
    end

    it 'all type-specific operator sets include EQUALITY_OPERATORS' do
      [
        described_class::STRING_OPERATORS,
        described_class::DATE_OPERATORS,
        described_class::NUMERIC_OPERATORS,
        described_class::UUID_OPERATORS,
        described_class::BOOLEAN_OPERATORS
      ].each do |operator_set|
        described_class::EQUALITY_OPERATORS.each do |op|
          expect(operator_set).to include(op)
        end
      end
    end
  end

  describe 'constants are frozen' do
    it 'EQUALITY_OPERATORS is frozen' do
      expect(described_class::EQUALITY_OPERATORS).to be_frozen
    end

    it 'STRING_OPERATORS is frozen' do
      expect(described_class::STRING_OPERATORS).to be_frozen
    end

    it 'OPERATORS_BY_TYPE is frozen' do
      expect(described_class::OPERATORS_BY_TYPE).to be_frozen
    end
  end
end
