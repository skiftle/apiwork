# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class OpFieldTransformer
        class << self
          def transform(params)
            return params unless params.is_a?(Hash)

            params.transform_values do |value|
              case value
              when Hash
                transform_op_field(transform(value))
              when Array
                value.map { |item| item.is_a?(Hash) ? transform_op_field(transform(item)) : item }
              else
                value
              end
            end
          end

          private

          def transform_op_field(hash)
            return hash unless hash.key?(:_op)

            result = hash.dup
            op = result.delete(:_op)
            result[:_destroy] = true if op == 'delete'
            result
          end
        end
      end
    end
  end
end
