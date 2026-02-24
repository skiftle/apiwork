# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::Param::Unknown do
  describe '#unknown?' do
    it 'returns true when unknown' do
      expect(described_class.new(type: :unknown).unknown?).to be(true)
    end
  end
end
