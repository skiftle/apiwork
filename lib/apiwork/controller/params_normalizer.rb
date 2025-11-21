# frozen_string_literal: true

module Apiwork
  module Controller
    module ParamsNormalizer
      module_function

      def call(params)
        normalize_indexed_hashes(params)
      end

      def normalize_indexed_hashes(params)
        return params unless params.is_a?(Hash)

        params.transform_values do |value|
          normalize_indexed_value(value)
        end
      end

      def normalize_indexed_value(value)
        return value unless value.is_a?(Hash) || value.is_a?(Array)
        return value.map { |v| normalize_indexed_value(v) } if value.is_a?(Array)

        return convert_indexed_hash_to_array(value) if indexed_hash?(value)

        normalize_indexed_hashes(value)
      end

      def convert_indexed_hash_to_array(hash)
        hash.keys.sort_by { |k| k.to_s.to_i }.map { |key| normalize_indexed_value(hash[key]) }
      end

      def indexed_hash?(hash)
        return false if hash.empty?

        hash.keys.all? { |k| k.to_s =~ /^\d+$/ }
      end

      private :normalize_indexed_hashes, :normalize_indexed_value,
              :convert_indexed_hash_to_array, :indexed_hash?
    end
  end
end
