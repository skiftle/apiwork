# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Export do
  describe '.find' do
    it 'returns the export' do
      export_class = described_class.find(:openapi)

      expect(export_class).to eq(Apiwork::Export::OpenAPI)
    end

    it 'returns nil when not found' do
      expect(described_class.find(:nonexistent)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns the export' do
      export_class = described_class.find!(:openapi)

      expect(export_class).to eq(Apiwork::Export::OpenAPI)
    end

    it 'raises KeyError when not found' do
      expect do
        described_class.find!(:nonexistent)
      end.to raise_error(KeyError, /nonexistent/)
    end
  end

  describe '.register' do
    it 'registers the export' do
      export_class = Class.new(Apiwork::Export::Base) do
        export_name :unit_export_register
      end
      described_class.register(export_class)

      expect(described_class.find(:unit_export_register)).to eq(export_class)
    end
  end
end
