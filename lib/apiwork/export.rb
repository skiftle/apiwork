# frozen_string_literal: true

module Apiwork
  # @api public
  # Namespace for export generators and the export registry.
  module Export
    class << self
      # @!method find(name)
      #   @api public
      #   Finds an export by name.
      #   @param name [Symbol] the export name
      #   @return [Class<Export::Base>, nil]
      #   @see .find!
      #   @example
      #     Apiwork::Export.find(:openapi)
      #
      # @!method find!(name)
      #   @api public
      #   Finds an export by name.
      #   @param name [Symbol] the export name
      #   @return [Class<Export::Base>]
      #   @raise [KeyError] if the export is not found
      #   @see .find
      #   @example
      #     Apiwork::Export.find!(:openapi)
      #
      # @!method register(klass)
      #   @api public
      #   Registers an export.
      #   @param klass [Class<Export::Base>] the export class with export_name set
      #   @see Export::Base
      #   @example
      #     Apiwork::Export.register(JSONSchemaExport)
      delegate :clear!,
               :exists?,
               :find,
               :find!,
               :keys,
               :register,
               :values,
               to: Registry

      # @api public
      # Generates an export for an API.
      #
      # @param export_name [Symbol] registered export name (built-in: :openapi, :typescript, :zod)
      # @param api_path [String] the API path
      # @param format [Symbol, nil] (nil) [:json, :yaml] hash exports only
      # @param locale [Symbol, nil] (nil) locale for translations
      # @param key_format [Symbol, nil] (nil) [:camel, :underscore, :kebab, :keep]
      # @param options export-specific keyword arguments
      # @return [String]
      # @raise [ConfigurationError] if export is not declared for the API
      # @see Export::Base
      #
      # @example
      #   Apiwork::Export.generate(:openapi, '/api/v1')
      #   Apiwork::Export.generate(:openapi, '/api/v1', format: :yaml)
      #   Apiwork::Export.generate(:typescript, '/api/v1', key_format: :camel)
      def generate(export_name, api_path, format: nil, key_format: nil, locale: nil, **options)
        export_class = find!(export_name)
        export_class.generate(api_path, format:, key_format:, locale:, **options)
      end

      def register_defaults!
        register(OpenAPI)
        register(TypeScript)
        register(Zod)
      end
    end
  end
end
