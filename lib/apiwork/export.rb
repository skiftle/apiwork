# frozen_string_literal: true

module Apiwork
  # @api public
  module Export
    class << self
      delegate :all,
               :find,
               :registered?,
               to: Registry

      # @api public
      # Registers an export.
      #
      # @param klass [Class] an {Export::Base} subclass with export_name set
      # @see Export::Base
      #
      # @example
      #   Apiwork::Export.register(JSONSchemaExport)
      delegate :register, to: Registry

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

      def reset!
        Registry.clear!
      end
    end
  end
end
