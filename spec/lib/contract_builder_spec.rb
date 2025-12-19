# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Apiwork::ContractBuilder do
  before do
    load File.expand_path('../dummy/config/apis/v1.rb', __dir__)
  end

  let(:api) { Apiwork::API::Registry.find('/api/v1') }
  let(:post_contract) { api.contracts[:post] }

  describe 'response type building' do
    let(:introspection) { api.introspect }
    let(:types) { introspection[:types] }

    it 'response attributes do not have optional set' do
      post_type = types[:post]
      expect(post_type).not_to be_nil

      post_shape = post_type[:shape]
      expect(post_shape).to be_a(Hash)

      post_shape.each do |attr_name, attr_def|
        next if attr_name == :author || attr_name == :comments || attr_name == :tags || attr_name == :taggings

        expect(attr_def).not_to have_key(:optional),
          "Response attribute #{attr_name} should not have optional key, but got: #{attr_def.inspect}"
      end
    end

    it 'response attributes can be nullable based on schema' do
      post_type = types[:post]
      post_shape = post_type[:shape]

      nullable_attrs = post_shape.select { |_, v| v[:nullable] == true }
      expect(nullable_attrs).not_to be_empty
    end
  end

  describe 'request type building' do
    let(:introspection) { api.introspect }
    let(:types) { introspection[:types] }

    it 'request attributes have optional when schema defines them as optional' do
      create_payload = types[:create_payload] || types[:post_create_payload]
      expect(create_payload).not_to be_nil

      payload_shape = create_payload[:shape]

      optional_attrs = payload_shape.select { |_, v| v[:optional] == true }
      expect(optional_attrs).not_to be_empty
    end

    it 'request attributes have nullable when schema defines them as nullable' do
      create_payload = types[:create_payload] || types[:post_create_payload]
      expect(create_payload).not_to be_nil

      payload_shape = create_payload[:shape]

      nullable_attrs = payload_shape.select { |_, v| v[:nullable] == true }
      expect(nullable_attrs).not_to be_empty
    end
  end

  describe 'response vs request attribute semantics' do
    let(:introspection) { api.introspect }
    let(:types) { introspection[:types] }

    it 'response attributes are always present (not optional) but may be null' do
      post_type = types[:post]
      post_shape = post_type[:shape]

      post_shape.each do |attr_name, attr_def|
        next if [:author, :comments, :tags, :taggings].include?(attr_name)

        expect(attr_def[:optional]).to be_falsy,
          "Response attribute #{attr_name} should not be optional"
      end
    end

    it 'associations can be optional in response (when not always included)' do
      post_type = types[:post]
      post_shape = post_type[:shape]

      association_attrs = post_shape.slice(:author, :comments, :tags, :taggings)
      optional_associations = association_attrs.select { |_, v| v[:optional] == true }

      expect(optional_associations).not_to be_empty,
        'Some associations should be optional when not always included'
    end
  end
end
