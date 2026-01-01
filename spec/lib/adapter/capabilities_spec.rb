# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capabilities do
  let(:structure) do
    instance_double(
      Apiwork::API::Structure,
      has_index_actions?: false,
      has_resources?: false,
      schema_classes: [],
    )
  end

  describe '#filterable?' do
    it 'returns true when filter_types is not empty' do
      capabilities = described_class.new(structure)
      allow(capabilities).to receive(:filter_types).and_return([:string, :integer])

      expect(capabilities.filterable?).to be true
    end

    it 'returns false when filter_types is empty' do
      capabilities = described_class.new(structure)

      expect(capabilities.filterable?).to be false
    end
  end
end
