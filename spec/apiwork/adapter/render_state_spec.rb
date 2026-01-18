# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::RenderState do
  def build_action(name, method, type: nil)
    Apiwork::Adapter::Action.new(name, method, type)
  end

  describe '#action' do
    it 'returns the action' do
      action = build_action(:show, :get, type: :member)
      state = described_class.new(action)
      expect(state.action).to eq(action)
    end
  end

  describe '#context' do
    it 'defaults to empty hash' do
      action = build_action(:show, :get)
      state = described_class.new(action)
      expect(state.context).to eq({})
    end

    it 'stores provided context' do
      action = build_action(:show, :get)
      state = described_class.new(action, context: { user_id: 1 })
      expect(state.context).to eq({ user_id: 1 })
    end
  end

  describe '#meta' do
    it 'defaults to empty hash' do
      action = build_action(:show, :get)
      state = described_class.new(action)
      expect(state.meta).to eq({})
    end

    it 'stores provided meta' do
      action = build_action(:show, :get)
      state = described_class.new(action, meta: { total: 100 })
      expect(state.meta).to eq({ total: 100 })
    end
  end

  describe '#request' do
    it 'defaults to nil' do
      action = build_action(:show, :get)
      state = described_class.new(action)
      expect(state.request).to be_nil
    end

    it 'stores provided request' do
      action = build_action(:index, :get)
      request = Apiwork::Adapter::Request.new(body: {}, query: { page: { size: 10 } })
      state = described_class.new(action, request:)
      expect(state.request).to eq(request)
      expect(state.request.query).to eq({ page: { size: 10 } })
    end
  end

  describe 'accessing action predicates' do
    it 'allows access via action.index?' do
      action = build_action(:index, :get, type: :collection)
      state = described_class.new(action)
      expect(state.action.index?).to be true
      expect(state.action.collection?).to be true
      expect(state.action.get?).to be true
    end

    it 'allows access via action.show?' do
      action = build_action(:show, :get, type: :member)
      state = described_class.new(action)
      expect(state.action.show?).to be true
      expect(state.action.member?).to be true
    end
  end
end
