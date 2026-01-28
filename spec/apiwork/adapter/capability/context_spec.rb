# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Context do
  def build_action(name, method, type: nil)
    Apiwork::Adapter::Action.new(name, method, type)
  end

  describe '#action' do
    it 'returns the action' do
      action = build_action(:show, :get, type: :member)
      context = described_class.new(action:)
      expect(context.action).to eq(action)
    end
  end

  describe '#context' do
    it 'defaults to empty hash' do
      action = build_action(:show, :get)
      context = described_class.new(action:)
      expect(context.context).to eq({})
    end

    it 'stores provided context' do
      action = build_action(:show, :get)
      context = described_class.new(action:, context: { user_id: 1 })
      expect(context.context).to eq({ user_id: 1 })
    end
  end

  describe '#meta' do
    it 'defaults to empty hash' do
      action = build_action(:show, :get)
      context = described_class.new(action:)
      expect(context.meta).to eq({})
    end

    it 'stores provided meta' do
      action = build_action(:show, :get)
      context = described_class.new(action:, meta: { total: 100 })
      expect(context.meta).to eq({ total: 100 })
    end
  end

  describe '#request' do
    it 'defaults to nil' do
      action = build_action(:show, :get)
      context = described_class.new(action:)
      expect(context.request).to be_nil
    end

    it 'stores provided request' do
      action = build_action(:index, :get)
      request = Apiwork::Adapter::Request.new(body: {}, query: { page: { size: 10 } })
      context = described_class.new(action:, request:)
      expect(context.request).to eq(request)
      expect(context.request.query).to eq({ page: { size: 10 } })
    end
  end

  describe 'accessing action predicates' do
    it 'allows access via action.index?' do
      action = build_action(:index, :get, type: :collection)
      context = described_class.new(action:)
      expect(context.action.index?).to be true
      expect(context.action.collection?).to be true
      expect(context.action.get?).to be true
    end

    it 'allows access via action.show?' do
      action = build_action(:show, :get, type: :member)
      context = described_class.new(action:)
      expect(context.action.show?).to be true
      expect(context.action.member?).to be true
    end
  end
end
