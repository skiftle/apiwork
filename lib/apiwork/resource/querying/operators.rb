# frozen_string_literal: true

module Apiwork
  module Resource
    module Querying
      # Centralized operator definitions for different data types
      #
      # This module provides a DRY way to define operators for filtering.
      # Operators are composed from base sets to avoid duplication.
      #
      # @example Using operators in filter validation
      #   unless STRING_OPERATORS.include?(operator)
      #     raise ArgumentError, "Invalid operator. Valid: #{STRING_OPERATORS.join(', ')}"
      #   end
      #
      module Operators
        # ============================================================
        # BASE OPERATOR SETS
        # ============================================================
        # These are shared across multiple data types

        # Equality operators - supported by all types
        EQUALITY_OPERATORS = %i[equal not_equal].freeze

        # Comparison operators - for ordered types (dates, numbers)
        COMPARISON_OPERATORS = %i[
          greater_than
          greater_than_or_equal_to
          less_than
          less_than_or_equal_to
        ].freeze

        # Range operators - for types that support ranges
        RANGE_OPERATORS = %i[between not_between].freeze

        # Collection operators - for checking membership
        COLLECTION_OPERATORS = %i[in not_in].freeze

        # String-specific operators
        STRING_SPECIFIC_OPERATORS = %i[
          contains
          not_contains
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

        # Get valid operators for a given data type
        #
        # @param type [Symbol] The data type
        # @return [Array<Symbol>] Valid operators for the type
        #
        # @example
        #   Operators.for_type(:string)  # => [:equal, :not_equal, :contains, ...]
        #   Operators.for_type(:integer) # => [:equal, :not_equal, :greater_than, ...]
        #
        def self.for_type(type)
          OPERATORS_BY_TYPE[type] || EQUALITY_OPERATORS
        end

        # Check if an operator is valid for a given type
        #
        # @param operator [Symbol] The operator to check
        # @param type [Symbol] The data type
        # @return [Boolean] True if operator is valid for type
        #
        # @example
        #   Operators.valid?(  :contains, :string)  # => true
      end
    end
  end
end
