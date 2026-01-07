# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ContractError do
  let(:issue) { Apiwork::Issue.new(code: :required, detail: 'is required', path: [:name]) }

  it 'inherits from ConstraintError' do
    expect(described_class.superclass).to eq(Apiwork::ConstraintError)
  end

  describe '#layer' do
    it 'returns :contract' do
      error = described_class.new(issue)
      expect(error.layer).to eq(:contract)
    end
  end

  describe '#status' do
    it 'inherits 400 from ConstraintError' do
      error = described_class.new(issue)
      expect(error.status).to eq(400)
    end
  end
end
