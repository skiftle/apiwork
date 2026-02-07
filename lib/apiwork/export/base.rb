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

      option :key_format, enum: %i[keep camel underscore kebab], type: :symbol
      option :locale, default: nil, type: :symbol

      attr_reader :api_path,
                  :options

      class << self
        attr_reader :output_type

        # @api public
        # The export name.
        #
        # @param name [Symbol, nil] the export name to set
        # @return [Symbol, nil]
        def export_name(name = nil)
          @export_name = name.to_sym if name
          @export_name
        end

        # @api public
        # The output type for this export.
        #
        # @param type [Symbol, nil] :hash for Hash output (json/yaml), :string for String output
        # @return [Symbol, nil]
        def output(type = nil)
          return @output_type unless type

          raise ArgumentError, "output must be :hash or :string, got #{type.inspect}" unless %i[hash string].include?(type)

          @output_type = type
        end

        def generate(api_path, format: nil, **options)
          format ||= :json

          raise ArgumentError, "#{export_name} export does not support #{format} format" if hash_output? && !supports_format?(format)

          export = new(api_path, **options)
          content = export.generate
          export.serialize(content, format:)
        end

        def hash_output?
          output_type == :hash
        end

        def string_output?
          output_type == :string
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
            file_extension
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

        # @api public
        # The file extension for string exports.
        #
        # Only valid for exports with `output :string`. Hash exports derive
        # their extension from the format (:json becomes .json, :yaml becomes .yaml).
        #
        # @param value [String, nil] the file extension (e.g., '.ts')
        # @return [String, nil]
        def file_extension(value = nil)
          return @file_extension unless value

          raise ConfigurationError, 'file_extension not allowed for output :hash exports' if output_type == :hash

          @file_extension = value
        end

        def extract_options(source)
          result = {}

          options.each do |name, option|
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

      def initialize(api_path, key_format: nil, locale: nil, **options)
        @api_path = api_path
        @api_class = API.find!(api_path)

        unless @api_class.export_configs.key?(self.class.export_name)
          raise ConfigurationError,
                "Export :#{self.class.export_name} is not declared for #{api_path}. " \
                "Add `export :#{self.class.export_name}` to your API definition."
        end

        config = @api_class.export_configs[self.class.export_name]
        api_config = extract_options_from_config(config)
        all_options = options.merge(key_format:, locale:).compact
        @options = self.class.default_options.merge(api_config).merge(all_options)
        @options[:key_format] ||= @api_class.key_format || :keep
        validate_options!

        @introspection = @api_class.introspect(locale: @options[:locale])
      end

      def extract_options_from_config(config)
        self.class.options.keys.each_with_object({}) do |key, hash|
          value = config.public_send(key)
          hash[key] = value unless value.nil?
        end
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
      # The API introspection facade.
      #
      # This is the primary interface for accessing introspection data in export generators.
      #
      # @return [Introspection::API]
      # @see Introspection::API
      def data
        @introspection
      end

      # @api public
      # The key format for this export.
      #
      # @return [Symbol]
      def key_format
        @options[:key_format]
      end

      # @api public
      # Transforms a key according to the configured key format.
      #
      # @param key [String, Symbol] the key to transform
      # @return [String]
      def transform_key(key)
        key_string = key.to_s

        return key_string if key_string.match?(/\A[A-Z]+\z/)

        case key_format
        when :camel then key_string.camelize(:lower)
        when :kebab then key_string.dasherize
        when :underscore then key_string.underscore
        else key_string
        end
      end
    end
  end
end
