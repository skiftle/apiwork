# frozen_string_literal: true

module Apiwork
  # @api public
  # Registry for spec generators.
  #
  # Built-in specs: :openapi, :typescript, :zod, :introspection.
  # Use {.generate} to produce specs for an API.
  module Spec
    class << self
      # @api public
      # Registers a spec generator.
      #
      # @param klass [Class] a {Spec::Base} subclass with spec_name set
      # @see Spec::Base
      #
      # @example
      #   Apiwork::Spec.register(JSONSchemaSpec)
      def register(klass)
        Registry.register(klass)
      end

      def find(spec_name)
        Registry.find(spec_name)
      end

      def all
        Registry.all
      end

      def registered?(spec_name)
        Registry.registered?(spec_name)
      end

      # @api public
      # Generates a spec for an API.
      #
      # @param spec_name [Symbol] the spec name (:openapi, :typescript, :zod)
      # @param api_path [String] the API mount path
      # @param format [Symbol] output format (:json, :yaml) - only for data specs
      # @param locale [Symbol, nil] locale for translations (default: nil)
      # @param key_format [Symbol, nil] key casing (:camel, :underscore, :kebab, :keep)
      # @param version [String, nil] spec version (spec-specific)
      # @return [String] the generated spec
      # @raise [ArgumentError] if format is not supported by the spec
      # @see Spec::Base
      #
      # @example
      #   Apiwork::Spec.generate(:openapi, '/api/v1')
      #   Apiwork::Spec.generate(:openapi, '/api/v1', format: :yaml)
      #   Apiwork::Spec.generate(:typescript, '/api/v1', locale: :sv, key_format: :camel)
      def generate(spec_name, api_path, format: nil, key_format: nil, locale: nil, version: nil)
        find(spec_name)&.generate(api_path, format:, key_format:, locale:, version:)
      end

      # @api public
      # Clears all registered specs. Intended for test cleanup.
      #
      # @example
      #   Apiwork::Spec.reset!
      def reset!
        Registry.clear!
      end
    end
  end
end
