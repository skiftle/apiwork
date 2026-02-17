# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Capability::Transformer::Response::Base do
  describe '#initialize' do
    it 'creates with required attributes' do
      response = Apiwork::Response.new(body: {})
      transformer = described_class.new(response)

      expect(transformer.response).to eq(response)
    end
  end

  describe '#transform' do
    it 'raises NotImplementedError' do
      transformer = described_class.new(nil)

      expect { transformer.transform }.to raise_error(NotImplementedError)
    end
  end
end
