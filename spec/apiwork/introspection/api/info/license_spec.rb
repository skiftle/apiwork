# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::API::Info::License do
  describe '#initialize' do
    it 'creates with required attributes' do
      license = described_class.new(name: 'MIT', url: 'https://example.com/alice.jpg')

      expect(license.name).to eq('MIT')
      expect(license.url).to eq('https://example.com/alice.jpg')
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      license = described_class.new(name: 'MIT', url: 'https://example.com/alice.jpg')

      expect(license.to_h).to eq(
        {
          name: 'MIT',
          url: 'https://example.com/alice.jpg',
        },
      )
    end
  end
end
