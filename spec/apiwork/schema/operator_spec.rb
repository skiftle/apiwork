# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Schema::Operator do
  describe 'BASE OPERATOR SETS' do
    it 'defines EQUALITY_OPERATORS' do
      expect(described_class::EQUALITY_OPERATORS).to eq(%i[eq])
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
      expect(described_class::RANGE_OPERATORS).to eq(%i[between])
    end

    it 'defines COLLECTION_OPERATORS' do
      expect(described_class::COLLECTION_OPERATORS).to eq(%i[in])
    end

    it 'defines STRING_SPECIFIC_OPERATORS' do
      expect(described_class::STRING_SPECIFIC_OPERATORS).to eq(%i[
                                                                 contains
                                                                 starts_with
                                                                 ends_with
                                                               ])
    end
  end

  describe 'TYPE-SPECIFIC OPERATOR SETS' do
    describe 'STRING_OPERATORS' do
      it 'includes equality, collection, and string-specific operators' do
        expect(described_class::STRING_OPERATORS).to include(
          :eq, # equality
          :in, # collection
          :contains, :starts_with # string-specific
        )
      end

      it 'does not include comparison operators' do
        expect(described_class::STRING_OPERATORS).not_to include(:gt, :lt)
      end
    end

    describe 'DATE_OPERATORS' do
      it 'includes equality, comparison, range, and collection operators' do
        expect(described_class::DATE_OPERATORS).to include(
          :eq, # equality
          :gt, :lt, # comparison
          :between, # range
          :in # collection
        )
      end

      it 'does not include string-specific operators' do
        expect(described_class::DATE_OPERATORS).not_to include(:contains, :starts_with)
      end
    end

    describe 'NUMERIC_OPERATORS' do
      it 'includes equality, comparison, range, and collection operators' do
        expect(described_class::NUMERIC_OPERATORS).to include(
          :eq, # equality
          :gt, :lt, # comparison
          :between, # range
          :in # collection
        )
      end
    end

    describe 'UUID_OPERATORS' do
      it 'includes only equality and collection operators' do
        expect(described_class::UUID_OPERATORS).to eq(%i[
                                                        eq
                                                        in
                                                      ])
      end

      it 'does not include comparison or range operators' do
        expect(described_class::UUID_OPERATORS).not_to include(:gt, :between)
      end
    end

    describe 'BOOLEAN_OPERATORS' do
      it 'includes only equality operators' do
        expect(described_class::BOOLEAN_OPERATORS).to eq(%i[eq])
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
  end
end
