# frozen_string_literal: true

module Apiwork
  module Transform
    module Case
      # Strategies for transforming case conventions
      # Returns strings (not symbols) - symbolization happens in hash() method
      STRATEGIES = {
        underscore: ->(value) { value.to_s.underscore },
        camelize_lower: ->(value) { value.to_s.camelize(:lower) },
        camelize_upper: ->(value) { value.to_s.camelize(:upper) },
        dasherize: ->(value) { value.to_s.dasherize },
        none: lambda(&:to_s)
      }.freeze

      def self.hash(hash, strategy)
        return hash if [:none, nil].include?(strategy)

        transformer = STRATEGIES.fetch(strategy) do
          raise ConfigurationError,
                "Unknown case transform strategy: #{strategy}. " \
                "Valid strategies: #{valid_strategies.join(', ')}"
        end

        hash.deep_transform_keys do |key|
          transformer.call(key).to_sym
        end
      end

      def self.string(string, strategy)
        return string.to_s if [:none, nil].include?(strategy)

        transformer = STRATEGIES.fetch(strategy) do
          raise ConfigurationError,
                "Unknown case transform strategy: #{strategy}. " \
                "Valid strategies: #{valid_strategies.join(', ')}"
        end

        transformer.call(string)
      end

      def self.valid_strategies
        STRATEGIES.keys
      end
    end
  end
end
