# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Standard::IncludesResolver do
  let(:representation_class) { Class.new }
  let(:resolver) { described_class.new(representation_class) }

  describe '#merge' do
    it 'merges two hash structures' do
      base = { author: {}, comments: { replies: {} } }
      override = { comments: { author: {} }, tags: {} }

      result = resolver.merge(base, override)

      expect(result).to eq(
        {
          author: {},
          comments: { author: {}, replies: {} },
          tags: {},
        },
      )
    end

    it 'handles symbol and string keys consistently' do
      base = { author: {} }
      override = { 'author' => { profile: {} } }

      result = resolver.merge(base, override)

      expect(result[:author]).to eq({ profile: {} })
    end

    it 'does not modify the original hash' do
      base = { author: {} }
      override = { comments: {} }

      resolver.merge(base, override)

      expect(base).to eq({ author: {} })
    end
  end
end
