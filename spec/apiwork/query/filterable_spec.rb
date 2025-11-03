# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Resource::Querying::Filter, type: :apiwork do
  let(:resource_class) do
    test_resource_class do
      attribute :name, filterable: true
      attribute :email, filterable: true
      attribute :age, filterable: true
      attribute :created_at, filterable: true
    end
  end

  describe 'module inclusion' do
    it 'includes Filter module' do
      expect(resource_class.ancestors).to include(Apiwork::Resource::Querying::Filter)
    end

    it 'responds to apply_filter method' do
      expect(resource_class).to respond_to(:apply_filter)
    end
  end

  describe 'filterable attributes' do
    it 'tracks filterable attributes' do
      expect(resource_class.filterable_attributes).to include(:name, :email, :age, :created_at)
    end

    it 'excludes non-filterable attributes' do
      expect(resource_class.filterable_attributes).not_to include(:password)
    end
  end

  describe 'error handling with ErrorHandler' do
    before do
      Apiwork.configuration.error_handling_mode = :silent
    end

    context 'with invalid filter attribute' do
      it 'uses ErrorHandler for non-filterable attribute' do
        expect(Apiwork::Errors::Handler).to receive(:handle)
          .with(instance_of(ArgumentError), hash_including(:context))

        resource_class.send(:build_where_conditions, { password: 'secret' })
      end
    end

    context 'with invalid operator' do
      it 'uses ErrorHandler for invalid string operator' do
        Apiwork.configuration.error_handling_mode = :silent

        expect(Apiwork::Errors::Handler).to receive(:handle)

        # Create a simple mock model with arel_table
        mock_model = double('Model', arel_table: double('ArelTable', :[] => double('Column')))

        resource_class.send(:build_string_where_clause, :name, { invalid_op: 'value' }, mock_model)
      end
    end

    context 'with invalid value type' do
      it 'uses ErrorHandler for invalid date value' do
        Apiwork.configuration.error_handling_mode = :silent

        expect(Apiwork::Errors::Handler).to receive(:handle)

        resource_class.send(:parse_date, 'not-a-date')
      end

      it 'uses ErrorHandler for invalid numeric value' do
        Apiwork.configuration.error_handling_mode = :silent

        expect(Apiwork::Errors::Handler).to receive(:handle)

        resource_class.send(:parse_numeric, 'not-a-number')
      end
    end
  end
end