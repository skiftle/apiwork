# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering < Adapter::Capability::Base
          class RequestTransformer < Adapter::Capability::Transformer::Request::Base
            NUMERIC_KEY_PATTERN = /^\d+$/

            phase :before

            def transform
              request.transform(&method(:transform_value))
            end

            private

            def transform_value(value)
              case value
              when Hash then apply(value)
              when Array then value.map(&method(:transform_value))
              else value
              end
            end

            def apply(hash)
              return to_array(hash) if indexed_hash?(hash)

              hash.transform_values(&method(:transform_value))
            end

            def to_array(hash)
              hash.keys.sort_by { |key| key.to_s.to_i }.map { |key| transform_value(hash[key]) }
            end

            def indexed_hash?(hash)
              return false if hash.empty?

              hash.keys.all? { |key| NUMERIC_KEY_PATTERN.match?(key.to_s) }
            end
          end
        end
      end
    end
  end
end
