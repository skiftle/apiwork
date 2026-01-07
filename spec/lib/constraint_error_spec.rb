# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::ConstraintError do
  let(:issue) do
    Apiwork::Issue.new(
      code: :required,
      detail: 'is required',
      path: [:name],
    )
  end

  describe '#issues' do
    it 'wraps a single issue in an array' do
      error = described_class.new(issue)
      expect(error.issues).to eq([issue])
    end

    it 'accepts an array of issues' do
      issues = [issue, Apiwork::Issue.new(code: :type, detail: 'must be string', path: [:email])]
      error = described_class.new(issues)
      expect(error.issues).to eq(issues)
    end
  end

  describe '#message' do
    it 'joins issue details with semicolons' do
      issues = [
        Apiwork::Issue.new(code: :required, detail: 'name is required', path: [:name]),
        Apiwork::Issue.new(code: :type, detail: 'email must be string', path: [:email]),
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

RSpec.describe Apiwork::DomainError do
  let(:issue) { Apiwork::Issue.new(code: :invalid, detail: 'is invalid', path: [:amount]) }

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

RSpec.describe Apiwork::ConfigurationError do
  it 'inherits from Error' do
    expect(described_class.superclass).to eq(Apiwork::Error)
  end

  it 'can be raised with a message' do
    expect { raise described_class, 'Invalid configuration' }.to raise_error(
      described_class, 'Invalid configuration'
    )
  end
end
