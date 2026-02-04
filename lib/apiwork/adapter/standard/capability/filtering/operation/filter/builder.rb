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
                            :field_name

                def initialize(column, field_name, allowed_types:)
                  @column = column
                  @field_name = field_name
                  @allowed_types = Array(allowed_types)
                end

                def build(value, normalizer: nil, valid_operators:, &block)
                  value = normalize_value(value, normalizer) if normalizer
                  return nil unless valid_value_type?(value)

                  builder = OperatorBuilder.new(column, field_name, valid_operators:)
                  builder.build(value, &block)
                end

                private

                def normalize_value(value, normalizer)
                  normalizer.call(value)
                end

                def valid_value_type?(value)
                  return true if allowed_types.empty?

                  allowed_types.any? { |type| value.is_a?(type) }
                end
              end
            end
          end
        end
      end
    end
  end
end
