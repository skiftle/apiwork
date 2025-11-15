# frozen_string_literal: true

module Apiwork
  module Controller
    # Normalizes Rails params by converting hashes with numeric string keys to arrays
    #
    # Rails converts URL params like filter[_or][0][title]=foo&filter[_or][1][body]=bar
    # into { filter: { _or: { '0' => { title: 'foo' }, '1' => { body: 'bar' } } } }
    #
    # This module converts them back to arrays:
    # { filter: { _or: [{ title: 'foo' }, { body: 'bar' }] } }
    #
    # Usage:
    #   ParamsNormalizer.call(params)
    #
    module ParamsNormalizer
      # Normalize params by converting indexed hashes to arrays
      def self.call(params)
        normalize_indexed_hashes(params)
      end

      # Recursively normalize hashes with numeric string keys to arrays
      def self.normalize_indexed_hashes(params)
        return params unless params.is_a?(Hash)

        params.transform_values do |value|
          normalize_indexed_value(value)
        end
      end

      # Normalize a single value (recursive)
      def self.normalize_indexed_value(value)
        return value if !value.is_a?(Hash) && !value.is_a?(Array)
        return value.map { |v| normalize_indexed_value(v) } if value.is_a?(Array)

        # Handle hash: check if numeric-indexed or regular nested hash
        return convert_indexed_hash_to_array(value) if indexed_hash?(value)

        normalize_indexed_hashes(value)
      end

      # Convert indexed hash to array, preserving numeric order
      def self.convert_indexed_hash_to_array(hash)
        hash.keys.sort_by { |k| k.to_s.to_i }.map { |key| normalize_indexed_value(hash[key]) }
      end

      # Check if hash has only numeric string keys
      def self.indexed_hash?(hash)
        return false if hash.empty?

        hash.keys.all? { |k| k.to_s =~ /^\d+$/ }
      end

      private_class_method :normalize_indexed_hashes, :normalize_indexed_value,
                           :convert_indexed_hash_to_array, :indexed_hash?
    end
  end
end
