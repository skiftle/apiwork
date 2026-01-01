# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Action do
  describe '#type predicates' do
    it 'returns true for member? when type is :member' do
      action = described_class.new(:show, :get, :member)
      expect(action.member?).to be true
    end

    it 'returns false for member? when type is :collection' do
      action = described_class.new(:index, :get, :collection)
      expect(action.member?).to be false
    end

    it 'returns true for collection? when type is :collection' do
      action = described_class.new(:index, :get, :collection)
      expect(action.collection?).to be true
    end

    it 'returns false for collection? when type is :member' do
      action = described_class.new(:show, :get, :member)
      expect(action.collection?).to be false
    end

    it 'returns false for both when type is nil' do
      action = described_class.new(:show, :get, nil)
      expect(action.member?).to be false
      expect(action.collection?).to be false
    end
  end

  describe '#name predicates' do
    it 'returns true for index?' do
      action = described_class.new(:index, :get, :collection)
      expect(action.index?).to be true
    end

    it 'returns true for show?' do
      action = described_class.new(:show, :get, :member)
      expect(action.show?).to be true
    end

    it 'returns true for create?' do
      action = described_class.new(:create, :post, :collection)
      expect(action.create?).to be true
    end

    it 'returns true for update?' do
      action = described_class.new(:update, :patch, :member)
      expect(action.update?).to be true
    end

    it 'returns true for destroy?' do
      action = described_class.new(:destroy, :delete, :member)
      expect(action.destroy?).to be true
    end

    it 'returns false for custom actions' do
      action = described_class.new(:archive, :patch, :member)
      expect(action.index?).to be false
      expect(action.show?).to be false
      expect(action.create?).to be false
      expect(action.update?).to be false
      expect(action.destroy?).to be false
    end
  end

  describe '#method predicates' do
    it 'returns true for get?' do
      action = described_class.new(:index, :get, :collection)
      expect(action.get?).to be true
    end

    it 'returns true for post?' do
      action = described_class.new(:create, :post, :collection)
      expect(action.post?).to be true
    end

    it 'returns true for patch?' do
      action = described_class.new(:update, :patch, :member)
      expect(action.patch?).to be true
    end

    it 'returns true for put?' do
      action = described_class.new(:update, :put, :member)
      expect(action.put?).to be true
    end

    it 'returns true for delete?' do
      action = described_class.new(:destroy, :delete, :member)
      expect(action.delete?).to be true
    end
  end

  describe '#read? and #write?' do
    it 'returns true for read? on GET requests' do
      action = described_class.new(:index, :get, :collection)
      expect(action.read?).to be true
      expect(action.write?).to be false
    end

    it 'returns true for write? on POST requests' do
      action = described_class.new(:create, :post, :collection)
      expect(action.read?).to be false
      expect(action.write?).to be true
    end

    it 'returns true for write? on PATCH requests' do
      action = described_class.new(:update, :patch, :member)
      expect(action.read?).to be false
      expect(action.write?).to be true
    end

    it 'returns true for write? on DELETE requests' do
      action = described_class.new(:destroy, :delete, :member)
      expect(action.read?).to be false
      expect(action.write?).to be true
    end
  end
end
