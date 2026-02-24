# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Wrapper::Collection::Base do
  describe '#initialize' do
    it 'creates with required attributes' do
      data = [{ id: 1 }]
      metadata = { total: 5 }
      root_key = :invoices
      meta = { page: 1 }

      wrapper = described_class.new(data, metadata, root_key, meta)

      expect(wrapper.data).to eq(data)
      expect(wrapper.metadata).to eq(metadata)
      expect(wrapper.root_key).to eq(:invoices)
      expect(wrapper.meta).to eq(meta)
    end
  end
end
