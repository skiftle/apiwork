# frozen_string_literal: true

module Apiwork
  class Query
    # Unified filter builder that eliminates duplication across type-specific builders
    # Handles value normalization, type validation, and operator mapping
    class FilterBuilder
      attr_reader :column, :field_name, :issues, :allowed_types

      def initialize(column:, field_name:, issues:, allowed_types:)
        @column = column
        @field_name = field_name
        @issues = issues
        @allowed_types = Array(allowed_types)
      end

      # Build filter conditions with normalization and validation
      # Accepts a block that maps operators to Arel conditions
      def build(value, valid_operators:, normalizer: nil, &block)
        # Normalize simple values to operator hash
        value = normalize_value(value, normalizer) if normalizer

        # Validate value type
        return nil unless validate_value_type(value)

        # Build conditions using FilterOperatorBuilder
        builder = FilterOperatorBuilder.new(
          column: column,
          field_name: field_name,
          valid_operators: valid_operators,
          issues: issues
        )

        builder.build(value, &block)
      end

      private

      def normalize_value(value, normalizer)
        normalizer.call(value)
      end

      def validate_value_type(value)
        return true if allowed_types.empty?
        return true if allowed_types.any? { |type| value.is_a?(type) }

        issues << Issue.new(
          code: :invalid_filter_value_type,
          message: "Invalid value type for #{field_name}. Expected: #{allowed_types.map(&:name).join(' or ')}",
          path: [:filter, field_name],
          meta: { field: field_name, value_type: value.class.name, expected_types: allowed_types.map(&:name) }
        )
        false
      end
    end
  end
end
