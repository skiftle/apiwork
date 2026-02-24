# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Builder::API::Base do
  describe '#initialize' do
    it 'creates with required attributes' do
      api_class = Class.new(Apiwork::API::Base)
      builder = described_class.new(api_class, data_type: :invoice)

      expect(builder.data_type).to eq(:invoice)
    end
  end

  describe '#build' do
    it 'raises NotImplementedError' do
      api_class = Class.new(Apiwork::API::Base)
      builder = described_class.new(api_class)

      expect { builder.build }.to raise_error(NotImplementedError)
    end
  end
end
