# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Apiwork::Adapter::Standard::Capability::Writing::Operation::IssueMapper do
  IssueMapperMockError = Struct.new(:attribute, :type, :options, keyword_init: true) do
    def initialize(attribute:, options: {}, type:)
      super(attribute:, options:, type:)
    end
  end

  IssueMapperMockAssociation = Struct.new(:name, keyword_init: true)

  def build_record_class(belongs_to: [], has_many: [], has_one: [])
    klass = Class.new do
      class << self
        attr_accessor :belongs_to_associations, :has_many_associations, :has_one_associations
      end

      def self.reflect_on_all_associations(type)
        case type
        when :has_many then has_many_associations
        when :has_one then has_one_associations
        when :belongs_to then belongs_to_associations
        end
      end
    end

    klass.has_many_associations = has_many.map { |name| IssueMapperMockAssociation.new(name:) }
    klass.has_one_associations = has_one.map { |name| IssueMapperMockAssociation.new(name:) }
    klass.belongs_to_associations = belongs_to.map { |name| IssueMapperMockAssociation.new(name:) }

    klass
  end

  def build_record(associations: {}, errors: [], record_class: nil)
    has_many_names = associations.select { |_, v| v[:type] == :has_many }.keys
    has_one_names = associations.select { |_, v| v[:type] == :has_one }.keys
    belongs_to_names = associations.select { |_, v| v[:type] == :belongs_to }.keys

    record_class ||= build_record_class(
      belongs_to: belongs_to_names,
      has_many: has_many_names,
      has_one: has_one_names,
    )

    klass = Class.new do
      attr_reader :associations_data, :errors

      def initialize(errors, associations_data, record_class)
        @record_class = record_class
        @associations_data = associations_data

        error_collection = Class.new do
          include Enumerable

          def initialize(errors)
            @errors = errors
          end

          def each(&block)
            @errors.each(&block)
          end

          def any?
            @errors.any?
          end
        end

        @errors = error_collection.new(errors)
      end

      def class
        @record_class
      end

      def respond_to?(method, *)
        method == :errors || super
      end

      def method_missing(method, *)
        return super unless associations_data.key?(method)

        associations_data.dig(method, :records) || associations_data.dig(method, :record)
      end

      def respond_to_missing?(method, *)
        associations_data.key?(method) || super
      end
    end

    klass.new(errors, associations, record_class)
  end

  describe '.map' do
    let(:translator) { ->(_, _, _) { nil } }
    let(:root_path) { [] }
    let(:issues) { described_class.map(record, translator, root_path:) }

    context 'when record does not respond to errors' do
      let(:record) do
        Class.new do
          def respond_to?(method, *)
            method != :errors
          end
        end.new
      end

      it 'returns empty array' do
        expect(issues).to eq([])
      end
    end

    context 'when record has no errors' do
      let(:record) { build_record(errors: []) }

      it 'returns empty array' do
        expect(issues).to eq([])
      end
    end

    context 'when record has blank error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :blank)])
      end

      it 'maps to :required code' do
        expect(issues.first.code).to eq(:required)
      end

      it 'includes path with attribute' do
        expect(issues.first.path).to eq([:number])
      end

      it 'includes detail from DETAIL_MAP' do
        expect(issues.first.detail).to eq('Required')
      end
    end

    context 'when record has empty error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :empty)])
      end

      it 'maps to :required code' do
        expect(issues.first.code).to eq(:required)
      end
    end

    context 'when record has taken error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :taken)])
      end

      it 'maps to :unique code' do
        expect(issues.first.code).to eq(:unique)
      end

      it 'includes detail from DETAIL_MAP' do
        expect(issues.first.detail).to eq('Already taken')
      end
    end

    context 'when record has too_long error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, options: { count: 50 }, type: :too_long)])
      end

      it 'maps to :max code' do
        expect(issues.first.code).to eq(:max)
      end

      it 'includes :max in meta' do
        expect(issues.first.meta).to eq({ max: 50 })
      end
    end

    context 'when record has too_short error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, options: { count: 3 }, type: :too_short)])
      end

      it 'maps to :min code' do
        expect(issues.first.code).to eq(:min)
      end

      it 'includes :min in meta' do
        expect(issues.first.meta).to eq({ min: 3 })
      end
    end

    context 'when record has wrong_length error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, options: { count: 10 }, type: :wrong_length)])
      end

      it 'maps to :length code' do
        expect(issues.first.code).to eq(:length)
      end

      it 'includes :exact in meta' do
        expect(issues.first.meta).to eq({ exact: 10 })
      end
    end

    context 'when record has inclusion error with range' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :quantity, options: { in: 1..100 }, type: :inclusion)])
      end

      it 'maps to :in code' do
        expect(issues.first.code).to eq(:in)
      end

      it 'includes range meta' do
        expect(issues.first.meta).to eq({ max: 100, max_exclusive: false, min: 1 })
      end
    end

    context 'when record has inclusion error with exclusive range' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :quantity, options: { in: 1...100 }, type: :inclusion)])
      end

      it 'includes max_exclusive: true in meta' do
        expect(issues.first.meta[:max_exclusive]).to be(true)
      end
    end

    context 'when record has greater_than error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, options: { count: 0 }, type: :greater_than)])
      end

      it 'maps to :gt code' do
        expect(issues.first.code).to eq(:gt)
      end

      it 'includes :gt in meta' do
        expect(issues.first.meta).to eq({ gt: 0 })
      end
    end

    context 'when record has greater_than_or_equal_to error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, options: { count: 1 }, type: :greater_than_or_equal_to)])
      end

      it 'maps to :gte code' do
        expect(issues.first.code).to eq(:gte)
      end

      it 'includes :gte in meta' do
        expect(issues.first.meta).to eq({ gte: 1 })
      end
    end

    context 'when record has less_than error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, options: { count: 1000 }, type: :less_than)])
      end

      it 'maps to :lt code' do
        expect(issues.first.code).to eq(:lt)
      end

      it 'includes :lt in meta' do
        expect(issues.first.meta).to eq({ lt: 1000 })
      end
    end

    context 'when record has less_than_or_equal_to error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, options: { count: 999 }, type: :less_than_or_equal_to)])
      end

      it 'maps to :lte code' do
        expect(issues.first.code).to eq(:lte)
      end

      it 'includes :lte in meta' do
        expect(issues.first.meta).to eq({ lte: 999 })
      end
    end

    context 'when record has equal_to error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, options: { count: 100 }, type: :equal_to)])
      end

      it 'maps to :eq code' do
        expect(issues.first.code).to eq(:eq)
      end

      it 'includes :eq in meta' do
        expect(issues.first.meta).to eq({ eq: 100 })
      end
    end

    context 'when record has other_than error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, options: { count: 0 }, type: :other_than)])
      end

      it 'maps to :ne code' do
        expect(issues.first.code).to eq(:ne)
      end

      it 'includes :ne in meta' do
        expect(issues.first.meta).to eq({ ne: 0 })
      end
    end

    context 'when record has not_a_number error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :total, type: :not_a_number)])
      end

      it 'maps to :number code' do
        expect(issues.first.code).to eq(:number)
      end
    end

    context 'when record has not_an_integer error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :quantity, type: :not_an_integer)])
      end

      it 'maps to :integer code' do
        expect(issues.first.code).to eq(:integer)
      end
    end

    context 'when record has even error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :quantity, type: :even)])
      end

      it 'maps to :even code' do
        expect(issues.first.code).to eq(:even)
      end
    end

    context 'when record has odd error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :quantity, type: :odd)])
      end

      it 'maps to :odd code' do
        expect(issues.first.code).to eq(:odd)
      end
    end

    context 'when record has base error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :base, type: :invalid)])
      end

      it 'maps to :invalid code' do
        expect(issues.first.code).to eq(:invalid)
      end

      it 'uses root_path without attribute' do
        expect(issues.first.path).to eq([])
      end
    end

    context 'when record has base error with custom root_path' do
      let(:root_path) { [:invoice] }
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :base, type: :invalid)])
      end

      it 'uses root_path only' do
        expect(issues.first.path).to eq([:invoice])
      end
    end

    context 'when record has unknown error type' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :custom_validation)])
      end

      it 'uses error type as code' do
        expect(issues.first.code).to eq(:custom_validation)
      end

      it 'humanizes code for detail' do
        expect(issues.first.detail).to eq('Custom validation')
      end
    end

    context 'when record has belongs_to association error' do
      let(:record) do
        build_record(
          associations: { customer: { type: :belongs_to } },
          errors: [IssueMapperMockError.new(attribute: :customer, type: :blank)],
        )
      end

      it 'appends _id to attribute name in path' do
        expect(issues.first.path).to eq([:customer_id])
      end
    end

    context 'when record has has_many association with errors' do
      let(:item_record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :description, type: :blank)])
      end
      let(:record) do
        build_record(
          associations: { items: { records: [item_record], type: :has_many } },
          errors: [IssueMapperMockError.new(attribute: :base, type: :invalid)],
        )
      end

      it 'includes association name in path' do
        association_issue = issues.find { |issue| issue.path.include?(:items) }
        expect(association_issue.path).to include(:items)
      end

      it 'includes index in path' do
        association_issue = issues.find { |issue| issue.path.include?(:items) }
        expect(association_issue.path).to eq([:items, 0, :description])
      end
    end

    context 'when record has has_many association with multiple errored items' do
      let(:item_record_1) do
        build_record(errors: [IssueMapperMockError.new(attribute: :description, type: :blank)])
      end
      let(:item_record_2) do
        build_record(errors: [IssueMapperMockError.new(attribute: :quantity, type: :blank)])
      end
      let(:record) do
        build_record(
          associations: { items: { records: [item_record_1, item_record_2], type: :has_many } },
          errors: [IssueMapperMockError.new(attribute: :base, type: :invalid)],
        )
      end

      it 'returns issues for parent and all items' do
        expect(issues.length).to eq(3)
      end

      it 'includes correct index for first item' do
        association_issues = issues.select { |issue| issue.path.include?(:items) }
        expect(association_issues.first.path).to eq([:items, 0, :description])
      end

      it 'includes correct index for second item' do
        association_issues = issues.select { |issue| issue.path.include?(:items) }
        expect(association_issues.last.path).to eq([:items, 1, :quantity])
      end
    end

    context 'when record has has_one association with errors' do
      let(:payment_record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :amount, type: :blank)])
      end
      let(:record) do
        build_record(
          associations: { payment: { record: payment_record, type: :has_one } },
          errors: [IssueMapperMockError.new(attribute: :base, type: :invalid)],
        )
      end

      it 'includes association name in path without index' do
        association_issue = issues.find { |issue| issue.path.include?(:payment) }
        expect(association_issue.path).to eq([:payment, :amount])
      end
    end

    context 'with custom root_path' do
      let(:root_path) { [:invoice] }
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :blank)])
      end

      it 'prepends root_path to issue path' do
        expect(issues.first.path).to eq([:invoice, :number])
      end
    end

    context 'with translator that returns detail' do
      let(:translator) { ->(_, code, _) { "Translated: #{code}" if code == :required } }
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :blank)])
      end

      it 'uses translator result for detail' do
        expect(issues.first.detail).to eq('Translated: required')
      end
    end

    context 'with translator that returns nil' do
      let(:translator) { ->(_, _, _) { nil } }
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, type: :blank)])
      end

      it 'falls back to DETAIL_MAP' do
        expect(issues.first.detail).to eq('Required')
      end
    end

    context 'when error has non-numeric count option' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :number, options: { count: 'many' }, type: :too_long)])
      end

      it 'excludes meta' do
        expect(issues.first.meta).to eq({})
      end
    end

    context 'when inclusion error has non-range :in option' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :status, options: { in: %w[draft sent] }, type: :inclusion)])
      end

      it 'excludes range meta' do
        expect(issues.first.meta).to eq({})
      end
    end

    context 'when record has nested attribute error' do
      let(:record) do
        build_record(errors: [IssueMapperMockError.new(attribute: :'items.description', type: :blank)])
      end

      it 'skips nested attribute errors' do
        expect(issues).to eq([])
      end
    end

    context 'when record has multiple errors on same attribute' do
      let(:record) do
        build_record(
          errors: [
            IssueMapperMockError.new(attribute: :number, type: :blank),
            IssueMapperMockError.new(attribute: :number, options: { count: 3 }, type: :too_short),
          ],
        )
      end

      it 'returns all errors' do
        expect(issues.length).to eq(2)
      end

      it 'maps first error correctly' do
        expect(issues.first.code).to eq(:required)
      end

      it 'maps second error correctly' do
        expect(issues.last.code).to eq(:min)
      end
    end
  end
end
