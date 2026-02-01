# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Features do
  let(:root_resource) do
    instance_double(
      Apiwork::API::Resource,
      has_index_actions?: false,
      has_resources?: false,
      representation_classes: [],
    )
  end

  describe '#filterable?' do
    it 'returns true when filter_types is not empty' do
      features = described_class.new(root_resource)
      allow(features).to receive(:filter_types).and_return([:string, :integer])

      expect(features.filterable?).to be true
    end

    it 'returns false when filter_types is empty' do
      features = described_class.new(root_resource)

      expect(features.filterable?).to be false
    end
  end
end
