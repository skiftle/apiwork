# frozen_string_literal: true

module Apiwork
  module Adapter
    class Standard
      module Capability
        class Filtering < Adapter::Capability::Base
          class IndexedHashRequestTransformer < Adapter::Transformer::Request::Base
            NUMERIC_KEY_PATTERN = /^\d+$/

            phase :before

            def transform
              request.transform { |hash| normalize_indexed_hashes(hash) }
            end

            private

            def normalize_indexed_hashes(params)
              return params unless params.is_a?(Hash)

              params.transform_values do |value|
                normalize_indexed_value(value)
              end
            end

            def normalize_indexed_value(value)
              return value unless value.is_a?(Hash) || value.is_a?(Array)
              return value.map { |element| normalize_indexed_value(element) } if value.is_a?(Array)
              return convert_indexed_hash_to_array(value) if indexed_hash?(value)

              normalize_indexed_hashes(value)
            end

            def convert_indexed_hash_to_array(hash)
              hash.keys.sort_by { |key| key.to_s.to_i }.map { |key| normalize_indexed_value(hash[key]) }
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
