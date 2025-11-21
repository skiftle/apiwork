# frozen_string_literal: true

module Apiwork
  module Schema
    module Operator
      EQUALITY_OPERATORS = %i[eq].freeze

      COMPARISON_OPERATORS = %i[
        gt
        gte
        lt
        lte
      ].freeze

      RANGE_OPERATORS = %i[between].freeze

      COLLECTION_OPERATORS = %i[in].freeze

      STRING_SPECIFIC_OPERATORS = %i[
        contains
        starts_with
        ends_with
      ].freeze

      NULL_OPERATORS = %i[null].freeze

      STRING_OPERATORS = (
        EQUALITY_OPERATORS +
        COLLECTION_OPERATORS +
        STRING_SPECIFIC_OPERATORS
      ).freeze

      DATE_OPERATORS = (
        EQUALITY_OPERATORS +
        COMPARISON_OPERATORS +
        RANGE_OPERATORS +
        COLLECTION_OPERATORS
      ).freeze

      NUMERIC_OPERATORS = (
        EQUALITY_OPERATORS +
        COMPARISON_OPERATORS +
        RANGE_OPERATORS +
        COLLECTION_OPERATORS
      ).freeze

      UUID_OPERATORS = (
        EQUALITY_OPERATORS +
        COLLECTION_OPERATORS
      ).freeze

      BOOLEAN_OPERATORS = EQUALITY_OPERATORS.freeze

      NULLABLE_STRING_OPERATORS = (STRING_OPERATORS + NULL_OPERATORS).freeze
      NULLABLE_DATE_OPERATORS = (DATE_OPERATORS + NULL_OPERATORS).freeze
      NULLABLE_NUMERIC_OPERATORS = (NUMERIC_OPERATORS + NULL_OPERATORS).freeze
      NULLABLE_UUID_OPERATORS = (UUID_OPERATORS + NULL_OPERATORS).freeze
      NULLABLE_BOOLEAN_OPERATORS = (BOOLEAN_OPERATORS + NULL_OPERATORS).freeze

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
