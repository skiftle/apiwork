# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Apiwork::IncludesResolver do
  before do
    load File.expand_path('../dummy/config/apis/v1.rb', __dir__)
  end

  let(:post_schema) { Api::V1::PostSchema }
  let(:resolver) { described_class.new(post_schema) }

  describe '#build' do
    context 'with no params' do
      it 'returns empty hash when no associations are always included' do
        result = resolver.build(params: {})
        expect(result).to eq({})
      end
    end

    context 'with explicit includes' do
      it 'includes requested associations' do
        result = resolver.build(params: { include: { comments: true } })
        expect(result).to eq({ comments: {} })
      end

      it 'excludes associations when set to false' do
        result = resolver.build(params: { include: { comments: false } })
        expect(result).not_to have_key(:comments)
      end

      it 'handles nested includes' do
        result = resolver.build(params: { include: { comments: { post: true } } })
        expect(result).to eq({ comments: { post: {} } })
      end

      it 'handles string keys' do
        result = resolver.build(params: { include: { 'comments' => true } })
        expect(result).to eq({ comments: {} })
      end

      it 'handles string values for boolean' do
        result = resolver.build(params: { include: { comments: 'true' } })
        expect(result).to eq({ comments: {} })

        result = resolver.build(params: { include: { comments: 'false' } })
        expect(result).not_to have_key(:comments)
      end
    end

    context 'with for_collection: false' do
      it 'does not extract from filter' do
        result = resolver.build(params: { filter: { comments: { content: 'test' } } }, for_collection: false)
        expect(result).not_to have_key(:comments)
      end
    end
  end

  describe '.deep_merge_includes' do
    it 'merges two hash structures' do
      base = { author: {}, comments: { replies: {} } }
      override = { comments: { author: {} }, tags: {} }

      result = described_class.deep_merge_includes(base, override)

      expect(result).to eq({
                             author: {},
                             comments: { replies: {}, author: {} },
                             tags: {}
                           })
    end

    it 'handles symbol and string keys consistently' do
      base = { author: {} }
      override = { 'author' => { profile: {} } }

      result = described_class.deep_merge_includes(base, override)

      expect(result[:author]).to eq({ profile: {} })
    end

    it 'does not modify the original hash' do
      base = { author: {} }
      override = { comments: {} }

      described_class.deep_merge_includes(base, override)

      expect(base).to eq({ author: {} })
    end
  end
end
