# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Standard::IncludesResolver do
  describe '.deep_merge_includes' do
    it 'merges two hash structures' do
      base = { author: {}, comments: { replies: {} } }
      override = { comments: { author: {} }, tags: {} }

      result = described_class.deep_merge_includes(base, override)

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
