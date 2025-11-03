# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Resource::Querying::Sort, type: :apiwork do
  let(:resource_class) do
    test_resource_class do
      attribute :name, sortable: true
      attribute :email, sortable: true
      attribute :age, sortable: true
      attribute :created_at, sortable: true
    end
  end

  describe 'module inclusion' do
    it 'includes Sort module' do
      expect(resource_class.ancestors).to include(Apiwork::Resource::Querying::Sort)
    end

    it 'responds to apply_sort method' do
      expect(resource_class).to respond_to(:apply_sort)
    end
  end

  describe 'sortable attributes' do
    it 'tracks sortable attributes' do
      expect(resource_class.sortable_attributes).to include(:name, :email, :age, :created_at)
    end

    it 'excludes non-sortable attributes' do
      expect(resource_class.sortable_attributes).not_to include(:password)
    end
  end
end