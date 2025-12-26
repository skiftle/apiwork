# frozen_string_literal: true

module Apiwork
  module Contract
    class ValidationResult
      attr_reader :issues,
                  :value,
                  :value_set

      def initialize(issues: [], value: nil, value_set: false)
        @issues = Array(issues)
        @value = value
        @value_set = value_set
      end

      def valid?
        issues.empty?
      end

      def invalid?
        issues.any?
      end

      def to_h
        result = { issues: issues, value_set: value_set }
        result[:value] = value if value_set
        result
      end

      class << self
        def success(value)
          new(value: value, value_set: true)
        end

        def skip
          new(value_set: false)
        end

        def failure(issue)
          new(issues: [issue], value_set: false)
        end

        def failures(issues)
          new(issues: issues, value_set: false)
        end
      end
    end
  end
end
