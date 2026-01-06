# frozen_string_literal: true

module Apiwork
  module Export
    # @api public
    # Base class for exports.
    #
    # Subclass this to create custom export formats. Declare output type
    # and override `#generate` to produce output.
    #
    # @example Hash export (supports json/yaml)
    #   class OpenAPI < Apiwork::Export::Base
    #     export_name :openapi
    #     output :hash
    #
    #     def generate
    #       { openapi: '3.1.0', ... }  # Returns Hash
    #     end
    #   end
    #
    # @example String export (fixed format)
    #   class ProtobufExport < Apiwork::Export::Base
    #     export_name :protobuf
    #     output :string
    #     file_extension '.proto'
    #
    #     def generate
    #       "syntax = \"proto3\";\n..."  # Returns String
    #     end
    #   end
    #
    #   # Register the export
    #   Apiwork::Export.register(ProtobufExport)
    class Base
      include Configurable

      class << self
        # @api public
        # Sets or returns the export name identifier.
        #
        # @param name [Symbol, nil] the export name to set
        # @return [Symbol, nil] the export name, or nil if not set
        def export_name(name = nil)
          @export_name = name.to_sym if name
          @export_name
        end

        # @api public
        # Declares the output type for this export.
        #
        # @param type [Symbol] :hash for Hash output (json/yaml), :string for String output
        def output(type = nil)
          return @output_type unless type

          raise ArgumentError, "output must be :hash or :string, got #{type.inspect}" unless %i[hash string].include?(type)

          @output_type = type
        end

        attr_reader :output_type

        def generate(api_path, format: nil, key_format: nil, locale: nil, version: nil)
          export = new(api_path, key_format:, locale:, version:)

          raise ArgumentError, "#{export_name} export does not support format options" if export.string_output? && format

          resolved_format = format || :json

          if export.hash_output? && !export.supports_format?(resolved_format)
            raise ArgumentError, "#{export_name} export does not support #{resolved_format} format"
          end

          content = export.generate
          export.serialize(content, format: resolved_format)
        end

        # @api public
        # Sets the file extension for string exports.
        #
        # Only valid for exports with `output :string`. Hash exports derive
        # their extension from the format (:json → .json, :yaml → .yaml).
        #
        # @param file_extension [String, nil] the file extension (e.g., '.ts')
        # @return [String, nil] the file extension
        def file_extension(file_extension = nil)
          return @file_extension unless file_extension

          raise ConfigurationError, 'file_extension not allowed for output :hash exports' if output_type == :hash

          @file_extension = file_extension
        end

        CORE_OPTIONS_TYPES = {
          format: :symbol,
          key_format: :symbol,
          locale: :symbol,
          version: :string,
        }.freeze

        def extract_options(source)
          result = {}

          CORE_OPTIONS_TYPES.each do |name, type|
            value = source[name] || source[name.to_s]
            next if value.nil?

            result[name] = type == :symbol ? value.to_sym : value
          end

          options.each do |name, option|
            next if CORE_OPTIONS_TYPES.key?(name)

            value = source[name] || source[name.to_s]
            next if value.nil?

            result[name] = if option.nested?
                             extract_nested_option(option, value)
                           else
                             option.cast(value)
                           end
          end

          result
        end

        def extract_nested_option(option, value)
          return nil unless value.is_a?(Hash)

          nested = {}
          option.children.each do |child_name, child_option|
            child_value = value[child_name] || value[child_name.to_s]
            next if child_value.nil?

            nested[child_name] = child_option.cast(child_value)
          end
          nested
        end

        def extract_options_from_env
          result = {}

          options.each do |name, option|
            if option.nested?
              nested = extract_nested_option_from_env(name, option)
              result[name] = nested if nested.any?
            else
              env_key = name.to_s.upcase
              value = ENV[env_key]
              result[name] = option.cast(value) unless value.nil?
            end
          end

          result
        end

        def extract_nested_option_from_env(parent_name, option)
          nested = {}
          prefix = parent_name.to_s.upcase

          option.children.each do |child_name, child_option|
            env_key = "#{prefix}_#{child_name.to_s.upcase}"
            value = ENV[env_key]
            next if value.nil?

            nested[child_name] = child_option.cast(value)
          end

          nested
        end
      end

      option :locale, default: nil, type: :symbol

      attr_reader :api_path,
                  :options

      def initialize(api_path, key_format: nil, locale: nil, version: nil)
        @api_path = api_path
        @api_class = API.find(api_path)
        raise "API not found at path: #{api_path}" unless @api_class

        @options = self.class.default_options
        @options[:key_format] = key_format || @api_class.key_format
        @options[:locale] = locale if locale
        @options[:version] = version if version
        validate_options!

        @introspection = @api_class.introspect(locale: @options[:locale])
      end

      def validate_options!
        @options.each do |name, value|
          option = self.class.options[name]
          option&.validate!(value)
        end
      end

      # @api public
      # Generates the export output.
      #
      # Override this method in subclasses to produce the export format.
      # Access API data via the {#data} method which provides typed access
      # to types, enums, resources, actions, and other introspection data.
      #
      # @return [Hash, String] Hash for hash exports, String for string exports
      # @see Introspection::API
      def generate
        raise NotImplementedError, "#{self.class} must implement #generate"
      end

      def hash_output?
        self.class.output_type == :hash
      end

      def string_output?
        self.class.output_type == :string
      end

      def supports_format?(format)
        return true if hash_output? && %i[json yaml].include?(format)

        false
      end

      def file_extension_for(format: nil)
        resolved = format || :json

        if hash_output?
          resolved == :yaml ? '.yaml' : '.json'
        else
          self.class.file_extension
        end
      end

      def content_type_for(format: nil)
        resolved = format || :json

        if hash_output?
          resolved == :yaml ? 'application/yaml' : 'application/json'
        else
          'text/plain; charset=utf-8'
        end
      end

      def serialize(content, format:)
        return content unless content.is_a?(Hash)

        case format
        when :yaml
          content.deep_stringify_keys.to_yaml
        else
          JSON.pretty_generate(content)
        end
      end

      # @api public
      # Returns the API introspection facade.
      #
      # This is the primary interface for accessing introspection data in export generators.
      #
      # @return [Introspection::API]
      # @see Introspection::API
      def data
        @introspection
      end

      def key_format
        @options[:key_format]
      end

      def version
        @options[:version]
      end

      def transform_key(key, strategy = nil)
        key = key.to_s
        strategy ||= key_format

        transform = lambda do |key_string|
          case strategy
          when :camel then key_string.camelize(:lower)
          when :kebab then key_string.dasherize
          when :underscore then key_string.underscore
          else key_string
          end
        end

        return transform.call(key) unless key.start_with?('_')

        prefix = key[/^_+/]
        "#{prefix}#{transform.call(key.delete_prefix(prefix))}"
      end
    end
  end
end
