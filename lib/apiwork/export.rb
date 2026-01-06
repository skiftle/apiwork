# frozen_string_literal: true

module Apiwork
  # @api public
  # Registry for export generators.
  #
  # Built-in exports: :openapi, :typescript, :zod, :introspection.
  # Use {.generate} to produce exports for an API.
  module Export
    class << self
      # @api public
      # Registers an export.
      #
      # @param klass [Class] an {Export::Base} subclass with export_name set
      # @see Export::Base
      #
      # @example
      #   Apiwork::Export.register(JSONSchemaExport)
      def register(klass)
        Registry.register(klass)
      end

      def find(export_name)
        Registry.find(export_name)
      end

      def all
        Registry.all
      end

      def registered?(export_name)
        Registry.registered?(export_name)
      end

      # @api public
      # Generates an export for an API.
      #
      # @param export_name [Symbol] the export name (:openapi, :typescript, :zod)
      # @param api_path [String] the API mount path
      # @param format [Symbol] output format (:json, :yaml) - only for data exports
      # @param locale [Symbol, nil] locale for translations (default: nil)
      # @param key_format [Symbol, nil] key casing (:camel, :underscore, :kebab, :keep)
      # @param version [String, nil] export version (export-specific)
      # @return [String] the generated export
      # @raise [ArgumentError] if format is not supported by the export
      # @see Export::Base
      #
      # @example
      #   Apiwork::Export.generate(:openapi, '/api/v1')
      #   Apiwork::Export.generate(:openapi, '/api/v1', format: :yaml)
      #   Apiwork::Export.generate(:typescript, '/api/v1', locale: :sv, key_format: :camel)
      def generate(export_name, api_path, format: nil, key_format: nil, locale: nil, version: nil)
        find(export_name)&.generate(api_path, format:, key_format:, locale:, version:)
      end

      # @api public
      # Clears all registered exports. Intended for test cleanup.
      #
      # @example
      #   Apiwork::Export.reset!
      def reset!
        Registry.clear!
      end
    end
  end
end
