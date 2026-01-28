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

  describe '#document_type' do
    it 'defaults to nil' do
      action = build_action(:show, :get)
      context = described_class.new(action:)
      expect(context.document_type).to be_nil
    end

    it 'stores provided document_type' do
      action = build_action(:index, :get)
      context = described_class.new(action:, document_type: :collection)
      expect(context.document_type).to eq(:collection)
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

  describe '#with_document_type' do
    it 'returns a new context with the document_type set' do
      action = build_action(:index, :get)
      context = described_class.new(action:, context: { user_id: 1 }, meta: { total: 100 })
      new_context = context.with_document_type(:collection)

      expect(new_context).not_to eq(context)
      expect(new_context.document_type).to eq(:collection)
      expect(new_context.action).to eq(action)
      expect(new_context.context).to eq({ user_id: 1 })
      expect(new_context.meta).to eq({ total: 100 })
    end

    it 'returns self if document_type is already set to same value' do
      action = build_action(:index, :get)
      context = described_class.new(action:, document_type: :collection)
      new_context = context.with_document_type(:collection)

      expect(new_context).to eq(context)
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
