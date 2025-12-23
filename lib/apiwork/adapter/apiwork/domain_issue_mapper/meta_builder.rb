# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class DomainIssueMapper
        class MetaBuilder
          NUMERIC_META_KEYS = {
            min: :count,
            max: :count,
            length: :count,
            gt: :count,
            gte: :count,
            lt: :count,
            lte: :count,
            eq: :count,
            ne: :count
          }.freeze

          META_KEY_MAP = {
            min: :min,
            max: :max,
            length: :exact,
            gt: :gt,
            gte: :gte,
            lt: :lt,
            lte: :lte,
            eq: :eq,
            ne: :ne
          }.freeze

          def self.call(code, error)
            new(code, error).call
          end

          def initialize(code, error)
            @code = code
            @error = error
          end

          def call
            return nil if @code == :custom
            return nil if @code == :invalid
            return nil unless @error.options

            build_meta
          end

          private

          def build_meta
            case @code
            when :min, :max, :length, :gt, :gte, :lt, :lte, :eq, :ne
              build_numeric_meta
            when :in
              build_range_meta
            else
              nil
            end
          end

          def build_numeric_meta
            source_key = NUMERIC_META_KEYS[@code]
            return nil unless source_key

            value = @error.options[source_key]
            return nil unless value.is_a?(Numeric)

            meta_key = META_KEY_MAP[@code]
            { meta_key => value }
          end

          def build_range_meta
            range = @error.options[:in]
            return nil unless range.is_a?(Range)
            return nil unless range.begin.is_a?(Numeric) && range.end.is_a?(Numeric)

            {
              min: range.begin,
              max: range.end,
              max_exclusive: range.exclude_end?
            }
          end
        end
      end
    end
  end
end
