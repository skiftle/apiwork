# frozen_string_literal: true

module Apiwork
  module Schema
    module Operator
      # ============================================================
      # BASE OPERATOR SETS
      # ============================================================
      # These are shared across multiple data types

      # Equality operators - supported by all types
      EQUALITY_OPERATORS = %i[eq].freeze

      # Comparison operators - for ordered types (dates, numbers)
      COMPARISON_OPERATORS = %i[
        gt
        gte
        lt
        lte
      ].freeze

      # Range operators - for types that support ranges
      RANGE_OPERATORS = %i[between].freeze

      # Collection operators - for checking membership
      COLLECTION_OPERATORS = %i[in].freeze

      # String-specific operators
      STRING_SPECIFIC_OPERATORS = %i[
        contains
        starts_with
        ends_with
      ].freeze

      # ============================================================
      # TYPE-SPECIFIC OPERATOR SETS
      # ============================================================

      # Valid operators for string/text fields
      # Includes: equality, collection, and string-specific
      STRING_OPERATORS = (
        EQUALITY_OPERATORS +
        COLLECTION_OPERATORS +
        STRING_SPECIFIC_OPERATORS
      ).freeze

      # Valid operators for date/datetime fields
      # Includes: equality, comparison, range, and collection
      DATE_OPERATORS = (
        EQUALITY_OPERATORS +
        COMPARISON_OPERATORS +
        RANGE_OPERATORS +
        COLLECTION_OPERATORS
      ).freeze

      # Valid operators for numeric fields (integer, float, decimal)
      # Includes: equality, comparison, range, and collection
      NUMERIC_OPERATORS = (
        EQUALITY_OPERATORS +
        COMPARISON_OPERATORS +
        RANGE_OPERATORS +
        COLLECTION_OPERATORS
      ).freeze

      # Valid operators for UUID fields
      # Only equality and collection operators
      UUID_OPERATORS = (
        EQUALITY_OPERATORS +
        COLLECTION_OPERATORS
      ).freeze

      # Boolean fields only support equality
      BOOLEAN_OPERATORS = EQUALITY_OPERATORS.freeze

      # ============================================================
      # OPERATOR METADATA
      # ============================================================

      # Map of data types to their valid operators
      # Useful for introspection and documentation
      OPERATORS_BY_TYPE = {
        string: STRING_OPERATORS,
        text: STRING_OPERATORS,
        date: DATE_OPERATORS,
        datetime: DATE_OPERATORS,
        integer: NUMERIC_OPERATORS,
        float: NUMERIC_OPERATORS,
        decimal: NUMERIC_OPERATORS,
        uuid: UUID_OPERATORS,
        boolean: BOOLEAN_OPERATORS
      }.freeze

      def self.for_type(type)
        OPERATORS_BY_TYPE[type] || EQUALITY_OPERATORS
      end
    end
  end
end
