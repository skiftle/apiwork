# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::StandardAdapter::DomainIssueMapper do
  let(:mapper_class) { described_class }

  def create_test_record(validations = {})
    Class.new do
      include ActiveModel::Model
      include ActiveModel::Validations

      attr_accessor :age,
                    :amount,
                    :status,
                    :title

      class << self
        attr_accessor :validation_config

        def reflect_on_all_associations(_type)
          []
        end
      end
    end.tap do |klass|
      klass.validation_config = validations
      validations.each do |attr, rules|
        klass.validates attr, rules
      end
    end
  end

  describe '.call' do
    it 'returns empty array when record has no errors' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: 'Valid')
      record.valid?

      issues = mapper_class.call(record)

      expect(issues).to eq([])
    end

    it 'returns empty array when record does not respond to errors' do
      record = Object.new

      issues = mapper_class.call(record)

      expect(issues).to eq([])
    end
  end

  describe 'code normalization' do
    it 'normalizes :blank to :required' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: '')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.code).to eq(:required)
    end

    it 'normalizes :too_short to :min' do
      record_class = create_test_record(title: { length: { minimum: 5 } })
      record = record_class.new(title: 'Hi')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.code).to eq(:min)
    end

    it 'normalizes :too_long to :max' do
      record_class = create_test_record(title: { length: { maximum: 5 } })
      record = record_class.new(title: 'Too long title')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.code).to eq(:max)
    end

    it 'normalizes :greater_than to :gt' do
      record_class = create_test_record(age: { numericality: { greater_than: 0 } })
      record = record_class.new(age: -1)
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.code).to eq(:gt)
    end

    it 'normalizes :inclusion to :in' do
      record_class = create_test_record(status: { inclusion: { in: %w[active inactive] } })
      record = record_class.new(status: 'unknown')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.code).to eq(:in)
    end

    it 'passes through unknown Rails codes as-is' do
      record_class = create_test_record({})
      record = record_class.new
      record.errors.add(:title, :disposable)

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.code).to eq(:disposable)
    end
  end

  describe 'detail messages' do
    it 'uses short Apiwork detail for :required' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: '')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.detail).to eq('Required')
    end

    it 'uses short Apiwork detail for :min' do
      record_class = create_test_record(title: { length: { minimum: 5 } })
      record = record_class.new(title: 'Hi')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.detail).to eq('Too short')
    end

    it 'uses short Apiwork detail for :max' do
      record_class = create_test_record(title: { length: { maximum: 5 } })
      record = record_class.new(title: 'Too long title')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.detail).to eq('Too long')
    end

    it 'humanizes unknown codes for detail' do
      record_class = create_test_record({})
      record = record_class.new
      record.errors.add(:title, :disposable_email)

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.detail).to eq('Disposable email')
    end
  end

  describe 'meta building' do
    it 'includes min count for :min code' do
      record_class = create_test_record(title: { length: { minimum: 5 } })
      record = record_class.new(title: 'Hi')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.meta).to eq({ min: 5 })
    end

    it 'includes max count for :max code' do
      record_class = create_test_record(title: { length: { maximum: 10 } })
      record = record_class.new(title: 'This is way too long')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.meta).to eq({ max: 10 })
    end

    it 'includes gt count for :gt code' do
      record_class = create_test_record(age: { numericality: { greater_than: 18 } })
      record = record_class.new(age: 10)
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.meta).to eq({ gt: 18 })
    end

    it 'returns empty meta for :required' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: '')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.meta).to eq({})
    end

    it 'returns empty meta for :custom' do
      record_class = create_test_record({})
      record = record_class.new
      record.errors.add(:title, :unknown_code)

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.meta).to eq({})
    end

    it 'does not expose array values from inclusion validation' do
      record_class = create_test_record(status: { inclusion: { in: %w[active inactive] } })
      record = record_class.new(status: 'unknown')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.first.meta).to eq({})
    end
  end

  describe 'path building' do
    it 'uses provided root_path' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: '')
      record.valid?

      issues = mapper_class.call(record, root_path: [:post])

      expect(issues.first.path).to eq([:post, :title])
    end

    it 'uses empty root_path by default' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: '')
      record.valid?

      issues = mapper_class.call(record)

      expect(issues.first.path).to eq([:title])
    end

    it 'handles nested root paths' do
      record_class = create_test_record(title: { presence: true })
      record = record_class.new(title: '')
      record.valid?

      issues = mapper_class.call(record, root_path: [:posts, 0])

      expect(issues.first.path).to eq([:posts, 0, :title])
    end
  end

  describe 'multiple errors' do
    it 'creates issues for all errors' do
      record_class = create_test_record(
        title: { presence: true },
        age: { numericality: { greater_than: 0 } },
      )
      record = record_class.new(age: -1, title: '')
      record.valid?

      issues = mapper_class.call(record, root_path: [:data])

      expect(issues.length).to eq(2)
      expect(issues.map(&:code)).to contain_exactly(:required, :gt)
    end
  end
end
