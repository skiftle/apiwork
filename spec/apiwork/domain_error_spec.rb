# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::DomainError do
  let(:issue) { Apiwork::Issue.new(:invalid, 'is invalid', path: [:amount]) }

  it 'inherits from ConstraintError' do
    expect(described_class.superclass).to eq(Apiwork::ConstraintError)
  end

  describe '#layer' do
    it 'returns :domain' do
      error = described_class.new(issue)
      expect(error.layer).to eq(:domain)
    end
  end

  describe '#status' do
    it 'returns 422 Unprocessable Entity' do
      error = described_class.new(issue)
      expect(error.status).to eq(422)
    end
  end

  describe '#error_code' do
    it 'returns the unprocessable_entity error code' do
      error = described_class.new(issue)
      expect(error.error_code).to eq(Apiwork::ErrorCode.fetch(:unprocessable_entity))
    end
  end
end
