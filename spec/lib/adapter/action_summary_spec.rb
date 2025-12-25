# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::ActionSummary do
  describe '#type' do
    it 'returns the action type when provided' do
      summary = described_class.new(:show, :get, type: :member)
      expect(summary.type).to eq(:member)
    end

    it 'returns nil when type is not provided' do
      summary = described_class.new(:show, :get)
      expect(summary.type).to be_nil
    end

    it 'converts string type to symbol' do
      summary = described_class.new(:show, :get, type: 'member')
      expect(summary.type).to eq(:member)
    end
  end

  describe '#member?' do
    it 'returns true when type is :member' do
      summary = described_class.new(:show, :get, type: :member)
      expect(summary.member?).to be true
    end

    it 'returns true for custom member actions' do
      summary = described_class.new(:archive, :patch, type: :member)
      expect(summary.member?).to be true
    end

    it 'returns false when type is :collection' do
      summary = described_class.new(:index, :get, type: :collection)
      expect(summary.member?).to be false
    end

    it 'returns false when type is nil' do
      summary = described_class.new(:show, :get)
      expect(summary.member?).to be false
    end
  end

  describe '#collection?' do
    it 'returns true when type is :collection' do
      summary = described_class.new(:index, :get, type: :collection)
      expect(summary.collection?).to be true
    end

    it 'returns true for custom collection actions' do
      summary = described_class.new(:search, :get, type: :collection)
      expect(summary.collection?).to be true
    end

    it 'returns false when type is :member' do
      summary = described_class.new(:show, :get, type: :member)
      expect(summary.collection?).to be false
    end

    it 'returns false when type is nil' do
      summary = described_class.new(:index, :get)
      expect(summary.collection?).to be false
    end
  end

  describe '#read?' do
    it 'returns true for GET requests' do
      summary = described_class.new(:index, :get)
      expect(summary.read?).to be true
    end

    it 'returns false for POST requests' do
      summary = described_class.new(:create, :post)
      expect(summary.read?).to be false
    end

    it 'returns false for PATCH requests' do
      summary = described_class.new(:update, :patch)
      expect(summary.read?).to be false
    end

    it 'returns false for DELETE requests' do
      summary = described_class.new(:destroy, :delete)
      expect(summary.read?).to be false
    end
  end

  describe '#write?' do
    it 'returns false for GET requests' do
      summary = described_class.new(:index, :get)
      expect(summary.write?).to be false
    end

    it 'returns true for POST requests' do
      summary = described_class.new(:create, :post)
      expect(summary.write?).to be true
    end

    it 'returns true for PATCH requests' do
      summary = described_class.new(:update, :patch)
      expect(summary.write?).to be true
    end

    it 'returns true for PUT requests' do
      summary = described_class.new(:update, :put)
      expect(summary.write?).to be true
    end

    it 'returns true for DELETE requests' do
      summary = described_class.new(:destroy, :delete)
      expect(summary.write?).to be true
    end
  end
end
