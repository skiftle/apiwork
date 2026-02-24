# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::API::Info::License do
  describe '#name' do
    it 'returns the name' do
      license = described_class.new
      license.name 'MIT'

      expect(license.name).to eq('MIT')
    end

    it 'returns nil when not set' do
      license = described_class.new

      expect(license.name).to be_nil
    end
  end

  describe '#url' do
    it 'returns the URL' do
      license = described_class.new
      license.url 'https://opensource.org/licenses/MIT'

      expect(license.url).to eq('https://opensource.org/licenses/MIT')
    end

    it 'returns nil when not set' do
      license = described_class.new

      expect(license.url).to be_nil
    end
  end
end
