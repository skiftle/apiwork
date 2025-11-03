# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Resource::Serialization, type: :apiwork do
  let(:resource_class) do
    test_resource_class do
      attribute :name, writable: true
      attribute :email, writable: true
      attribute :created_at, writable: false
    end
  end

  let(:model) do
    test_model_instance(
      name: 'Test User',
      email: 'test@example.com',
      created_at: Time.parse('2024-01-01')
    )
  end

  let(:context) { { user: double('User'), session: double('Session') } }

  describe '.serialize' do
    context 'with single object' do
      it 'serializes attributes' do
        result = resource_class.serialize(model, context)

        expect(result).to include(
          name: 'Test User',
          email: 'test@example.com'
        )
      end

    it 'includes timestamps' do
      result = resource_class.serialize(model, context)

      # Timestamps are camelCased by default
      expect(result).to have_key(:createdAt)
    end

    end

    context 'with collection' do
      let(:collection) { [model, model] }

      it 'serializes all objects' do
        result = resource_class.serialize(collection, context)

        expect(result).to be_an(Array)
        expect(result.size).to eq(2)
      end

      it 'each object has correct attributes' do
        result = resource_class.serialize(collection, context)

        result.each do |item|
          expect(item).to include(
            name: 'Test User',
            email: 'test@example.com'
          )
        end
      end
    end
  end



  describe 'root key' do
    it 'returns RootKey object' do
      root_key = resource_class.root_key
      expect(root_key).to be_a(Apiwork::Resource::RootKey)
    end

    it 'has singular method' do
      expect(resource_class.root_key.singular).to eq('test_model')
    end

    it 'has plural method' do
      expect(resource_class.root_key.plural).to eq('test_models')
    end

    it 'has type method' do
      expect(resource_class.type).to eq('test_model')
    end
  end

end
