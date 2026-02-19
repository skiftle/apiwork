# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Contract::Scope do
  let(:representation_class) do
    Class.new(Apiwork::Representation::Base) do
      model Invoice
      attribute :number, filterable: true, sortable: true
      attribute :status, filterable: true, writable: true
      attribute :notes, writable: true
      attribute :due_on, sortable: true
    end
  end

  let(:index_action) { Apiwork::API::Resource::Action.new(:index) }
  let(:show_action) { Apiwork::API::Resource::Action.new(:show) }
  let(:create_action) { Apiwork::API::Resource::Action.new(:create) }
  let(:search_action) { Apiwork::API::Resource::Action.new(:search, type: :collection) }

  let(:actions) do
    {
      create: create_action,
      index: index_action,
      search: search_action,
      show: show_action,
    }
  end

  let(:scope) { described_class.new(representation_class, actions) }

  describe '#initialize' do
    it 'creates with required attributes' do
      scope = described_class.new(representation_class, actions)

      expect(scope.representation_class).to eq(representation_class)
      expect(scope.actions).to eq(actions)
    end
  end

  describe '#collection_actions' do
    it 'returns actions with collection type' do
      result = scope.collection_actions

      expect(result.keys).to contain_exactly(:index, :search)
      expect(result[:index]).to eq(index_action)
      expect(result[:search]).to eq(search_action)
    end

    it 'returns empty hash when no collection actions' do
      scope = described_class.new(representation_class, { show: show_action })

      expect(scope.collection_actions).to eq({})
    end
  end

  describe '#member_actions' do
    it 'returns actions with member type' do
      result = scope.member_actions

      expect(result.keys).to contain_exactly(:show, :create)
      expect(result[:show]).to eq(show_action)
      expect(result[:create]).to eq(create_action)
    end

    it 'returns empty hash when no member actions' do
      scope = described_class.new(representation_class, { index: index_action })

      expect(scope.member_actions).to eq({})
    end
  end

  describe '#crud_actions' do
    it 'returns CRUD actions' do
      result = scope.crud_actions

      expect(result.keys).to contain_exactly(:index, :show, :create)
      expect(result[:index]).to eq(index_action)
      expect(result[:show]).to eq(show_action)
      expect(result[:create]).to eq(create_action)
    end

    it 'returns empty hash when no CRUD actions' do
      scope = described_class.new(representation_class, { search: search_action })

      expect(scope.crud_actions).to eq({})
    end
  end

  describe '#action?' do
    it 'returns true when action exists' do
      expect(scope.action?(:index)).to be(true)
      expect(scope.action?(:show)).to be(true)
    end

    it 'returns false when action does not exist' do
      expect(scope.action?(:destroy)).to be(false)
      expect(scope.action?(:unknown)).to be(false)
    end

    it 'converts string to symbol' do
      expect(scope.action?('index')).to be(true)
      expect(scope.action?('destroy')).to be(false)
    end
  end

  describe '#filterable_attributes' do
    it 'returns attributes with filterable flag' do
      result = scope.filterable_attributes

      expect(result.map(&:name)).to contain_exactly(:number, :status)
    end

    it 'returns empty array when no filterable attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Invoice
        attribute :number
      end
      scope = described_class.new(representation_class, actions)

      expect(scope.filterable_attributes).to eq([])
    end
  end

  describe '#sortable_attributes' do
    it 'returns attributes with sortable flag' do
      result = scope.sortable_attributes

      expect(result.map(&:name)).to contain_exactly(:number, :due_on)
    end

    it 'returns empty array when no sortable attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Invoice
        attribute :number
      end
      scope = described_class.new(representation_class, actions)

      expect(scope.sortable_attributes).to eq([])
    end
  end

  describe '#writable_attributes' do
    it 'returns attributes with writable flag' do
      result = scope.writable_attributes

      expect(result.map(&:name)).to contain_exactly(:status, :notes)
    end

    it 'returns empty array when no writable attributes' do
      representation_class = Class.new(Apiwork::Representation::Base) do
        model Invoice
        attribute :number
      end
      scope = described_class.new(representation_class, actions)

      expect(scope.writable_attributes).to eq([])
    end
  end

  describe '#attributes' do
    it 'delegates to representation_class' do
      expect(scope.attributes).to eq(representation_class.attributes)
    end
  end

  describe '#associations' do
    it 'delegates to representation_class' do
      expect(scope.associations).to eq(representation_class.associations)
    end
  end

  describe '#root_key' do
    it 'delegates to representation_class' do
      expect(scope.root_key.singular).to eq(representation_class.root_key.singular)
      expect(scope.root_key.plural).to eq(representation_class.root_key.plural)
    end
  end
end
