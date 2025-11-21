# frozen_string_literal: true

module Apiwork
  module Contract
    # Standardized result object for parameter validation
    # Replaces inline hash creation with consistent structure
    class ValidationResult
      attr_reader :issues, :value, :value_set

      def initialize(issues: [], value: nil, value_set: false)
        @issues = Array(issues)
        @value = value
        @value_set = value_set
      end

      # Check if validation succeeded (no issues)
      def success?
        issues.empty?
      end

      # Check if validation failed (has issues)
      def failure?
        !success?
      end

      # Convert to hash for backward compatibility
      def to_h
        result = { issues: issues, value_set: value_set }
        result[:value] = value if value_set
        result
      end

      # Class methods for common result patterns
      class << self
        # Success with value
        def success(value)
          new(value: value, value_set: true)
        end

        # Success without value (nil/skipped)
        def skip
          new(value_set: false)
        end

        # Failure with single issue
        def failure(issue)
          new(issues: [issue], value_set: false)
        end

        # Failure with multiple issues
        def failures(issues)
          new(issues: issues, value_set: false)
        end
      end
    end
  end
end
