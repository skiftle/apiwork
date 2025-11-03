# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Resource::Querying::Paginate, type: :apiwork do
  let(:resource_class) do
    test_resource_class do
      attribute :name, writable: true
      attribute :email, writable: true
    end
  end

  describe 'module inclusion' do
    it 'includes Paginate module' do
      expect(resource_class.ancestors).to include(Apiwork::Resource::Querying::Paginate)
    end

    it 'responds to apply_pagination method' do
      expect(resource_class).to respond_to(:apply_pagination)
    end

    it 'responds to build_pagination_metadata method' do
      expect(resource_class).to respond_to(:build_pagination_metadata)
    end
  end

  describe 'pagination configuration' do
    it 'has default page size' do
      expect(resource_class.default_page_size).to eq(20)
    end

    it 'has maximum page size' do
      expect(resource_class.maximum_page_size).to eq(200)
    end
  end
end