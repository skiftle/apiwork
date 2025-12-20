# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class Filter
          class Builder
            attr_reader :allowed_types,
                        :column,
                        :field_name,
                        :issues

            def initialize(column:, field_name:, issues:, allowed_types:)
              @column = column
              @field_name = field_name
              @issues = issues
              @allowed_types = Array(allowed_types)
            end

            def build(value, valid_operators:, normalizer: nil, &block)
              value = normalize_value(value, normalizer) if normalizer

              return nil unless validate_value_type(value)

              builder = OperatorBuilder.new(
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
                detail: "Invalid value type for #{field_name}. Expected: #{allowed_types.map(&:name).join(' or ')}",
                path: [:filter, field_name],
                meta: { field: field_name, value_type: value.class.name, expected_types: allowed_types.map(&:name) }
              )
              false
            end
          end
        end
      end
    end
  end
end
