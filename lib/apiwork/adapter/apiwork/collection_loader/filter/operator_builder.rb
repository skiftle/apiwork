# frozen_string_literal: true

module Apiwork
  module Adapter
    class Apiwork < Base
      class CollectionLoader
        class Filter
          class OperatorBuilder
            attr_reader :column,
                        :field_name,
                        :issues,
                        :valid_operators

            def initialize(column:, field_name:, valid_operators:, issues: [])
              @column = column
              @field_name = field_name
              @valid_operators = valid_operators
              @issues = issues
            end

            def build(operator_hash)
              operator_hash.map do |operator, compare_value|
                operator = operator.to_sym

                unless valid_operators.include?(operator)
                  add_invalid_operator_issue(operator)
                  next
                end

                yield(operator, compare_value)
              end.compact.reduce(:and)
            end

            private

            def add_invalid_operator_issue(operator)
              issues << Issue.new(
                code: :invalid_operator,
                detail: "Invalid operator '#{operator}' for #{field_name}. Valid: #{valid_operators.join(', ')}",
                path: [:filter, field_name, operator],
                meta: { field: field_name, operator: operator, valid_operators: valid_operators },
                layer: :contract
              )
            end
          end
        end
      end
    end
  end
end
