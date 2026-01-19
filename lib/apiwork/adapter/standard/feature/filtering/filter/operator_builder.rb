# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Feature
        class Filtering < Adapter::Feature
          class Filter
            class OperatorBuilder
              attr_reader :column,
                          :field_name,
                          :issues,
                          :valid_operators

              def initialize(column, field_name, issues: [], valid_operators:)
                @column = column
                @field_name = field_name
                @valid_operators = valid_operators
                @issues = issues
              end

              def build(operator_hash)
                operator_hash.filter_map do |operator, compare_value|
                  operator = operator.to_sym

                  unless valid_operators.include?(operator)
                    add_invalid_operator_issue(operator)
                    next
                  end

                  yield(operator, compare_value)
                end.reduce(:and)
              end

              private

              def add_invalid_operator_issue(operator)
                issues << Issue.new(
                  :operator_invalid,
                  'Invalid operator',
                  meta: {
                    operator:,
                    allowed: valid_operators,
                    field: field_name,
                  },
                  path: [:filter, field_name, operator],
                )
              end
            end
          end
        end
      end
    end
  end
end
