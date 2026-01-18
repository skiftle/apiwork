# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      class OpFieldTransformer
        def call(request)
          request.transform { |hash| transform_hash(hash) }
        end

        private

        def transform_hash(params)
          return params unless params.is_a?(Hash)

          params.transform_values do |value|
            case value
            when Hash
              transform_op_field(transform_hash(value))
            when Array
              value.map { |item| item.is_a?(Hash) ? transform_op_field(transform_hash(item)) : item }
            else
              value
            end
          end
        end

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
