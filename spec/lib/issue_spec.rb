# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Issue do
  describe '#initialize' do
    it 'creates an issue with required attributes' do
      issue = described_class.new(code: :required, detail: 'Field is required')

      expect(issue.code).to eq(:required)
      expect(issue.detail).to eq('Field is required')
      expect(issue.path).to eq([])
      expect(issue.meta).to eq({})
      expect(issue.layer).to be_nil
    end

    it 'accepts path and meta' do
      issue = described_class.new(
        code: :invalid_type,
        detail: 'Expected string',
        path: [:user, :name],
        meta: { expected: 'string', got: 'integer' }
      )

      expect(issue.path).to eq([:user, :name])
      expect(issue.meta).to eq({ expected: 'string', got: 'integer' })
    end

    it 'converts path elements to symbols (except integers)' do
      issue = described_class.new(
        code: :required,
        detail: 'Required',
        path: ['user', 'items', 0, 'name']
      )

      expect(issue.path).to eq([:user, :items, 0, :name])
    end
  end

  describe 'layer attribute' do
    it 'accepts :contract layer' do
      issue = described_class.new(code: :required, detail: 'Required', layer: :contract)

      expect(issue.layer).to eq('contract')
    end

    it 'accepts :domain layer' do
      issue = described_class.new(code: :blank, detail: "can't be blank", layer: :domain)

      expect(issue.layer).to eq('domain')
    end

    it 'accepts :http layer' do
      issue = described_class.new(code: :not_found, detail: 'Not found', layer: :http)

      expect(issue.layer).to eq('http')
    end

    it 'accepts string layer' do
      issue = described_class.new(code: :required, detail: 'Required', layer: 'contract')

      expect(issue.layer).to eq('contract')
    end

    it 'accepts nil layer for backwards compatibility' do
      issue = described_class.new(code: :required, detail: 'Required', layer: nil)

      expect(issue.layer).to be_nil
    end

    it 'raises error for invalid layer' do
      expect do
        described_class.new(code: :required, detail: 'Required', layer: :invalid)
      end.to raise_error(ArgumentError, /Invalid layer 'invalid'/)
    end
  end

  describe '#pointer' do
    it 'returns JSON pointer format' do
      issue = described_class.new(code: :required, detail: 'Required', path: [:user, :email])

      expect(issue.pointer).to eq('/user/email')
    end

    it 'handles array indices' do
      issue = described_class.new(code: :required, detail: 'Required', path: [:items, 0, :name])

      expect(issue.pointer).to eq('/items/0/name')
    end

    it 'returns empty string for empty path' do
      issue = described_class.new(code: :required, detail: 'Required', path: [])

      expect(issue.pointer).to eq('')
    end
  end

  describe '#to_h' do
    it 'includes layer nil when not provided' do
      issue = described_class.new(
        code: :required,
        detail: 'Field is required',
        path: [:user, :email],
        meta: { field: :email }
      )

      expect(issue.to_h).to eq({
                                 layer: nil,
                                 code: :required,
                                 detail: 'Field is required',
                                 path: %w[user email],
                                 pointer: '/user/email',
                                 meta: { field: :email }
                               })
    end

    it 'includes layer when present' do
      issue = described_class.new(
        code: :required,
        detail: 'Field is required',
        path: [:user, :email],
        meta: {},
        layer: :contract
      )

      hash = issue.to_h

      expect(hash[:layer]).to eq('contract')
    end

    it 'includes domain layer for model validations' do
      issue = described_class.new(
        code: :blank,
        detail: "can't be blank",
        path: [:user, :name],
        meta: { attribute: :name },
        layer: :domain
      )

      hash = issue.to_h

      expect(hash[:layer]).to eq('domain')
    end

    it 'includes http layer for respond_with_error' do
      issue = described_class.new(
        code: :not_found,
        detail: 'Resource not found',
        path: [],
        meta: {},
        layer: :http
      )

      hash = issue.to_h

      expect(hash[:layer]).to eq('http')
    end
  end

  describe '#as_json' do
    it 'returns the same as to_h' do
      issue = described_class.new(code: :required, detail: 'Required', layer: :contract)

      expect(issue.as_json).to eq(issue.to_h)
    end
  end

  describe '#to_s' do
    it 'formats issue as string' do
      issue = described_class.new(
        code: :required,
        detail: 'Field is required',
        path: [:user, :email]
      )

      expect(issue.to_s).to eq('[required] at /user/email Field is required')
    end

    it 'handles empty path' do
      issue = described_class.new(code: :invalid, detail: 'Invalid request')

      expect(issue.to_s).to eq('[invalid] Invalid request')
    end
  end

  describe 'VALID_LAYERS constant' do
    it 'defines the valid layer values' do
      expect(described_class::VALID_LAYERS).to contain_exactly('contract', 'domain', 'http')
    end
  end
end
