# frozen_string_literal: true

module Apiwork
  module Controller
    module Deserialization
      extend ActiveSupport::Concern

      included do
        before_action :validate_input
      end

      class_methods do
        def skip_validate_input!(only: nil, except: nil)
          skip_before_action :validate_input, only: only, except: except
        end
      end

      def action_input
        @action_input ||= begin
          parser = Contract::Parser.new(current_contract, :input, action_name, coerce: true)

          data = request.query_parameters.merge(request.request_parameters).deep_symbolize_keys
          data = Transform::Case.hash(data, key_transform)

          # Normalize hashes with numeric string keys to arrays (from URL params like filter[_or][0][...])
          data = normalize_indexed_hashes(data)

          parser.perform(data)
        end
      end

      private

      def validate_input
        return if action_input.valid?

        raise ContractError, action_input.issues
      end

      def key_transform
        Apiwork.configuration.deserialize_key_transform
      end

      # Recursively normalize hashes with numeric string keys to arrays
      def normalize_indexed_hashes(params)
        return params unless params.is_a?(Hash)

        params.transform_values do |value|
          normalize_indexed_value(value)
        end
      end

      # Normalize a single value (recursive)
      def normalize_indexed_value(value)
        return value unless value.is_a?(Hash) || value.is_a?(Array)
        return value.map { |v| normalize_indexed_value(v) } if value.is_a?(Array)

        # Handle hash: check if numeric-indexed or regular nested hash
        return convert_indexed_hash_to_array(value) if indexed_hash?(value)

        normalize_indexed_hashes(value)
      end

      # Convert indexed hash to array, preserving numeric order
      def convert_indexed_hash_to_array(hash)
        hash.keys.sort_by { |k| k.to_s.to_i }.map { |key| normalize_indexed_value(hash[key]) }
      end

      # Check if hash has only numeric string keys
      def indexed_hash?(hash)
        return false if hash.empty?

        hash.keys.all? { |k| k.to_s =~ /^\d+$/ }
      end
    end
  end
end
