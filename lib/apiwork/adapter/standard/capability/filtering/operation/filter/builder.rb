# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering
          class Operation < Adapter::Capability::Operation::Base
            class Filter
              class Builder
                attr_reader :allowed_types,
                            :column,
                            :field_name,
                            :issues

                def initialize(column, field_name, allowed_types:, issues:)
                  @column = column
                  @field_name = field_name
                  @issues = issues
                  @allowed_types = Array(allowed_types)
                end

                def build(value, normalizer: nil, valid_operators:, &block)
                  value = normalize_value(value, normalizer) if normalizer

                  return nil unless validate_value_type(value)

                  builder = OperatorBuilder.new(column, field_name, issues:, valid_operators:)

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
                    :filter_value_invalid,
                    'Invalid filter value',
                    meta: {
                      allowed: allowed_types.map(&:name),
                      field: field_name,
                      type: value.class.name,
                    },
                    path: [:filter, field_name],
                  )
                  false
                end
              end
            end
          end
        end
      end
    end
  end
end
