# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Schema::Operators do
  let(:test_class) do
    Class.new do
      include Apiwork::Schema::Operators
    end
  end

  describe 'constants' do
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

  describe 'composed operators' do
    it 'defines STRING_OPERATORS as composition' do
      expected = %i[eq neq in nin contains ncontains starts_with ends_with]
      expect(described_class::STRING_OPERATORS).to eq(expected)
    end

    it 'defines DATE_OPERATORS as composition' do
      expected = %i[
        eq
        neq
        gt
        gte
        lt
        lte
        between
        nbetween
        in
        nin
      ]
      expect(described_class::DATE_OPERATORS).to eq(expected)
    end

    it 'defines NUMERIC_OPERATORS as composition' do
      expected = %i[
        eq
        neq
        gt
        gte
        lt
        lte
        between
        nbetween
        in
        nin
      ]
      expect(described_class::NUMERIC_OPERATORS).to eq(expected)
    end

    it 'defines BOOLEAN_OPERATORS as composition' do
      expected = %i[eq neq]
      expect(described_class::BOOLEAN_OPERATORS).to eq(expected)
    end

    it 'defines UUID_OPERATORS as composition' do
      expected = %i[eq neq in nin]
      expect(described_class::UUID_OPERATORS).to eq(expected)
    end
  end

  describe 'immutability' do
    it 'freezes EQUALITY_OPERATORS' do
      expect(described_class::EQUALITY_OPERATORS).to be_frozen
    end

    it 'freezes COMPARISON_OPERATORS' do
      expect(described_class::COMPARISON_OPERATORS).to be_frozen
    end

    it 'freezes RANGE_OPERATORS' do
      expect(described_class::RANGE_OPERATORS).to be_frozen
    end

    it 'freezes COLLECTION_OPERATORS' do
      expect(described_class::COLLECTION_OPERATORS).to be_frozen
    end

    it 'freezes STRING_SPECIFIC_OPERATORS' do
      expect(described_class::STRING_SPECIFIC_OPERATORS).to be_frozen
    end

    it 'freezes STRING_OPERATORS' do
      expect(described_class::STRING_OPERATORS).to be_frozen
    end

    it 'freezes DATE_OPERATORS' do
      expect(described_class::DATE_OPERATORS).to be_frozen
    end

    it 'freezes NUMERIC_OPERATORS' do
      expect(described_class::NUMERIC_OPERATORS).to be_frozen
    end

    it 'freezes BOOLEAN_OPERATORS' do
      expect(described_class::BOOLEAN_OPERATORS).to be_frozen
    end

    it 'freezes UUID_OPERATORS' do
      expect(described_class::UUID_OPERATORS).to be_frozen
    end
  end

  describe 'module inclusion' do
    it 'can be included in a class' do
      expect { test_class }.not_to raise_error
    end

    it 'makes constants available to including class' do
      instance = test_class.new
      expect(test_class::STRING_OPERATORS).to eq(described_class::STRING_OPERATORS)
    end
  end

  describe 'DRY composition' do
    it 'does not duplicate operators across constants' do
      # STRING_OPERATORS should share base operators
      expect(described_class::STRING_OPERATORS & described_class::EQUALITY_OPERATORS)
        .to eq(described_class::EQUALITY_OPERATORS)

      # DATE_OPERATORS should share base operators
      expect(described_class::DATE_OPERATORS & described_class::EQUALITY_OPERATORS)
        .to eq(described_class::EQUALITY_OPERATORS)

      expect(described_class::DATE_OPERATORS & described_class::COMPARISON_OPERATORS)
        .to eq(described_class::COMPARISON_OPERATORS)

      # NUMERIC_OPERATORS should share base operators
      expect(described_class::NUMERIC_OPERATORS & described_class::EQUALITY_OPERATORS)
        .to eq(described_class::EQUALITY_OPERATORS)

      expect(described_class::NUMERIC_OPERATORS & described_class::COMPARISON_OPERATORS)
        .to eq(described_class::COMPARISON_OPERATORS)
    end
  end
end
