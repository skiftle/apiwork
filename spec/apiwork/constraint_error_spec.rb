# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ConstraintError do
  let(:issue) do
    Apiwork::Issue.new(
      :required,
      'is required',
      path: [:name],
    )
  end

  describe '#issues' do
    it 'wraps a single issue in an array' do
      error = described_class.new(issue)
      expect(error.issues).to eq([issue])
    end

    it 'accepts an array of issues' do
      issues = [issue, Apiwork::Issue.new(:type, 'must be string', path: [:email])]
      error = described_class.new(issues)
      expect(error.issues).to eq(issues)
    end
  end

  describe '#message' do
    it 'joins issue details with semicolons' do
      issues = [
        Apiwork::Issue.new(:required, 'name is required', path: [:name]),
        Apiwork::Issue.new(:type, 'email must be string', path: [:email]),
      ]
      error = described_class.new(issues)
      expect(error.message).to eq('name is required; email must be string')
    end
  end

  describe '#status' do
    it 'returns 400 Bad Request' do
      error = described_class.new(issue)
      expect(error.status).to eq(400)
    end
  end

  describe '#error_code' do
    it 'returns the bad_request error code' do
      error = described_class.new(issue)
      expect(error.error_code).to eq(Apiwork::ErrorCode.fetch(:bad_request))
    end
  end
end
