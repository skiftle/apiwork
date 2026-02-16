# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Union do
  describe '#variant' do
    it 'defines a variant' do
      union = described_class.new(discriminator: :type)
      union.variant(tag: 'card') do
        object do
          string :last_four
        end
      end

      expect(union.variants.length).to eq(1)
      expect(union.variants.first[:tag]).to eq('card')
      expect(union.variants.first[:type]).to eq(:object)
    end
  end
end
