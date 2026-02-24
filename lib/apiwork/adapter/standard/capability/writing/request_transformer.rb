# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Writing < Adapter::Capability::Base
          class RequestTransformer < Adapter::Capability::Transformer::Request::Base
            phase :after

            def transform
              request.transform_body(&method(:transform_value))
            end

            private

            def transform_value(value)
              case value
              when Hash then apply(value.transform_values(&method(:transform_value)))
              when Array then value.map(&method(:transform_value))
              else value
              end
            end

            def apply(hash)
              return hash unless hash.key?(Constants::OP)

              result = hash.except(Constants::OP)
              result[:_destroy] = true if hash[Constants::OP] == 'delete'
              result
            end
          end
        end
      end
    end
  end
end
