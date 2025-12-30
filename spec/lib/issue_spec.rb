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
    end

    it 'accepts path and meta' do
      issue = described_class.new(
        code: :type_invalid,
        detail: 'Expected string',
        meta: { expected: 'string', got: 'integer' },
        path: [:user, :name],
      )

      expect(issue.path).to eq([:user, :name])
      expect(issue.meta).to eq({ expected: 'string', got: 'integer' })
    end

    it 'converts path elements to symbols (except integers)' do
      issue = described_class.new(
        code: :required,
        detail: 'Required',
        path: ['user', 'items', 0, 'name'],
      )

      expect(issue.path).to eq([:user, :items, 0, :name])
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
    it 'includes all fields' do
      issue = described_class.new(
        code: :required,
        detail: 'Field is required',
        meta: { field: :email },
        path: [:user, :email],
      )

      expect(issue.to_h).to eq(
        {
          code: :required,
          detail: 'Field is required',
          meta: { field: :email },
          path: %w[user email],
          pointer: '/user/email',
        },
      )
    end
  end

  describe '#as_json' do
    it 'returns the same as to_h' do
      issue = described_class.new(code: :required, detail: 'Required')

      expect(issue.as_json).to eq(issue.to_h)
    end
  end

  describe '#to_s' do
    it 'formats issue as string' do
      issue = described_class.new(
        code: :required,
        detail: 'Field is required',
        path: [:user, :email],
      )

      expect(issue.to_s).to eq('[required] at /user/email Field is required')
    end

    it 'handles empty path' do
      issue = described_class.new(code: :invalid, detail: 'Invalid request')

      expect(issue.to_s).to eq('[invalid] Invalid request')
    end
  end
end
