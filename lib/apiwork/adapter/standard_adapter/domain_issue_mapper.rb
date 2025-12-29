# frozen_string_literal: true

module Apiwork
  module Adapter
    class StandardAdapter < Base
      class DomainIssueMapper
        CODE_MAP = {
          blank: :required,
          present: :forbidden,
          empty: :required,
          taken: :unique,
          accepted: :accepted,
          confirmation: :confirmed,
          too_short: :min,
          too_long: :max,
          wrong_length: :length,
          not_a_number: :number,
          not_an_integer: :integer,
          greater_than: :gt,
          greater_than_or_equal_to: :gte,
          less_than: :lt,
          less_than_or_equal_to: :lte,
          equal_to: :eq,
          other_than: :ne,
          odd: :odd,
          even: :even,
          inclusion: :in,
          exclusion: :not_in,
          in: :in,
          invalid: :invalid,
          restrict_dependent_destroy: :associated
        }.freeze

        DETAIL_MAP = {
          required: 'Required',
          forbidden: 'Must be blank',
          unique: 'Already taken',
          format: 'Invalid format',
          accepted: 'Must be accepted',
          confirmed: 'Does not match',
          min: 'Too short',
          max: 'Too long',
          length: 'Wrong length',
          number: 'Not a number',
          integer: 'Not an integer',
          gt: 'Too small',
          gte: 'Too small',
          lt: 'Too large',
          lte: 'Too large',
          eq: 'Wrong value',
          ne: 'Reserved value',
          odd: 'Must be odd',
          even: 'Must be even',
          in: 'Invalid value',
          not_in: 'Reserved value',
          associated: 'Invalid',
          invalid: 'Invalid'
        }.freeze

        META_CODES = %i[min max length gt gte lt lte eq ne in].freeze

        def self.call(record, locale_key: nil, root_path: [])
          new(record, root_path, locale_key).call
        end

        def initialize(record, root_path, locale_key)
          @record = record
          @root_path = Array(root_path)
          @locale_key = locale_key
        end

        def call
          return [] unless @record.respond_to?(:errors)
          return [] unless @record.errors.any?

          attribute_issues + association_issues
        end

        private

        def attribute_issues
          @record.errors.filter_map do |error|
            next if nested_attribute_error?(error)

            build_issue(error)
          end
        end

        def association_issues
          collect_association_issues(:has_many) + collect_association_issues(:has_one)
        end

        def collect_association_issues(association_type)
          result = []

          @record.class.reflect_on_all_associations(association_type).each do |association|
            associated = @record.send(association.name)
            next unless associated

            items = association_type == :has_many ? associated : [associated]
            next unless items.respond_to?(:each)

            items.each_with_index do |item, index|
              next unless item.respond_to?(:errors)
              next unless item.errors.any?

              nested_path = build_association_path(association.name, index, association_type)
              result.concat(self.class.call(item, locale_key: @locale_key, root_path: nested_path))
            end
          end

          result
        end

        def build_association_path(name, index, type)
          if type == :has_many
            @root_path + [name, index]
          else
            @root_path + [name]
          end
        end

        def nested_attribute_error?(error)
          error.attribute.to_s.include?('.')
        end

        def build_issue(error)
          code = normalize_code(error)
          attribute = resolve_attribute(error.attribute)
          path = attribute == :base ? @root_path : @root_path + [attribute]

          Issue.new(
            code:,
            detail: detail_for(code),
            path:,
            meta: build_meta(code, error)
          )
        end

        def normalize_code(error)
          return :invalid if error.attribute == :base

          CODE_MAP[error.type] || error.type
        end

        def detail_for(code)
          if @locale_key
            api_key = :"apiwork.apis.#{@locale_key}.adapters.standard.domain_issues.#{code}.detail"
            result = I18n.t(api_key, default: nil)
            return result if result
          end

          adapter_key = :"apiwork.adapters.standard.domain_issues.#{code}.detail"
          result = I18n.t(adapter_key, default: nil)
          return result if result

          DETAIL_MAP[code] || code.to_s.humanize
        end

        def build_meta(code, error)
          return {} unless META_CODES.include?(code)
          return {} unless error.options

          if code == :in
            build_range_meta(error)
          else
            build_numeric_meta(code, error)
          end
        end

        def build_numeric_meta(code, error)
          value = error.options[:count]
          return {} unless value.is_a?(Numeric)

          meta_key = code == :length ? :exact : code
          { meta_key => value }
        end

        def build_range_meta(error)
          range = error.options[:in]
          return {} unless range.is_a?(Range)
          return {} unless range.begin.is_a?(Numeric) && range.end.is_a?(Numeric)

          {
            min: range.begin,
            max: range.end,
            max_exclusive: range.exclude_end?
          }
        end

        def resolve_attribute(attribute)
          return attribute if attribute == :base
          return attribute unless belongs_to_association?(attribute)

          :"#{attribute}_id"
        end

        def belongs_to_association?(attribute)
          belongs_to_names.include?(attribute)
        end

        def belongs_to_names
          @belongs_to_names ||= @record.class.reflect_on_all_associations(:belongs_to).map(&:name)
        end
      end
    end
  end
end
