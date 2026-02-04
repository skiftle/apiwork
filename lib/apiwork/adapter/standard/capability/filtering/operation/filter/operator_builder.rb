# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Operation < Adapter::Capability::Operation::Base
            class Filter
              class OperatorBuilder
                attr_reader :column,
                            :field_name,
                            :valid_operators

                def initialize(column, field_name, valid_operators:)
                  @column = column
                  @field_name = field_name
                  @valid_operators = valid_operators
                end

                def build(operator_hash)
                  operator_hash.filter_map do |operator, compare_value|
                    operator = operator.to_sym
                    next unless valid_operators.include?(operator)

                    yield(operator, compare_value)
                  end.reduce(:and)
                end
              end
            end
          end
        end
      end
    end
  end
end
