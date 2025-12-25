# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::SchemaSummary do
  describe '#filterable?' do
    it 'returns true when filterable_types is not empty' do
      summary = described_class.new([])
      allow(summary).to receive(:filterable_types).and_return([:string, :integer])

      expect(summary.filterable?).to be true
    end

    it 'returns false when filterable_types is empty' do
      summary = described_class.new([])

      expect(summary.filterable?).to be false
    end
  end

  describe '#paginatable?' do
    it 'returns true when offset pagination is used' do
      summary = described_class.new([])
      allow(summary).to receive(:uses_offset_pagination?).and_return(true)

      expect(summary.paginatable?).to be true
    end

    it 'returns true when cursor pagination is used' do
      summary = described_class.new([])
      allow(summary).to receive(:uses_cursor_pagination?).and_return(true)

      expect(summary.paginatable?).to be true
    end

    it 'returns false when no pagination is used' do
      summary = described_class.new([])

      expect(summary.paginatable?).to be false
    end
  end
end
