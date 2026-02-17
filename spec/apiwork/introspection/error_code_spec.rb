# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Introspection::ErrorCode do
  describe '#initialize' do
    it 'creates with required attributes' do
      error_code = described_class.new(description: 'Resource not found', status: 404)

      expect(error_code.description).to eq('Resource not found')
      expect(error_code.status).to eq(404)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      error_code = described_class.new(description: 'Resource not found', status: 404)

      expect(error_code.to_h).to eq(
        {
          description: 'Resource not found',
          status: 404,
        },
      )
    end
  end
end
