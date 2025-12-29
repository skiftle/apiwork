# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::SchemaSummary do
  let(:structure) do
    instance_double(
      Apiwork::API::Structure,
      schema_classes: [],
      has_resources?: false,
      has_index_actions?: false
    )
  end

  describe '#filterable?' do
    it 'returns true when filterable_types is not empty' do
      summary = described_class.new(structure)
      allow(summary).to receive(:filterable_types).and_return([:string, :integer])

      expect(summary.filterable?).to be true
    end

    it 'returns false when filterable_types is empty' do
      summary = described_class.new(structure)

      expect(summary.filterable?).to be false
    end
  end

  describe '#paginatable?' do
    it 'returns true when offset pagination is used' do
      summary = described_class.new(structure)
      allow(summary).to receive(:uses_offset_pagination?).and_return(true)

      expect(summary.paginatable?).to be true
    end

    it 'returns true when cursor pagination is used' do
      summary = described_class.new(structure)
      allow(summary).to receive(:uses_cursor_pagination?).and_return(true)

      expect(summary.paginatable?).to be true
    end

    it 'returns false when no pagination is used' do
      summary = described_class.new(structure)

      expect(summary.paginatable?).to be false
    end
  end
end
