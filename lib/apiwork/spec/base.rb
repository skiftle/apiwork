# frozen_string_literal: true

module Apiwork
  module Spec
    # @api public
    # Base class for spec generators.
    #
    # Subclass this to create custom spec formats. Declare output type
    # and override `#generate` to produce output.
    #
    # @example Data spec (supports json/yaml)
    #   class OpenAPISpec < Apiwork::Spec::Base
    #     spec_name :openapi
    #     output :data
    #
    #     def generate
    #       { openapi: '3.1.0', ... }  # Returns Hash
    #     end
    #   end
    #
    # @example Text spec (fixed format)
    #   class ProtobufSpec < Apiwork::Spec::Base
    #     spec_name :protobuf
    #     output :text
    #     file_extension '.proto'
    #
    #     def generate
    #       "syntax = \"proto3\";\n..."  # Returns String
    #     end
    #   end
    #
    #   # Register the spec
    #   Apiwork::Spec.register(ProtobufSpec)
    class Base
      include Configurable

      class << self
        # @api public
        # Sets or returns the spec name identifier.
        #
        # @param name [Symbol, nil] the spec name to set
        # @return [Symbol, nil] the spec name, or nil if not set
        def spec_name(name = nil)
          @spec_name = name.to_sym if name
          @spec_name
        end

        # @api public
        # Declares the output type for this spec.
        #
        # @param type [Symbol] :data for Hash output (json/yaml), :text for String output
        def output(type = nil)
          return @output_type unless type

          raise ArgumentError, "output must be :data or :text, got #{type.inspect}" unless %i[data text].include?(type)

          @output_type = type
        end

        attr_reader :output_type
      end

      option :locale, default: nil, type: :symbol

      attr_reader :api_path,
                  :data,
                  :options

      class << self
        # @api public
        # Generates a spec for the given API path.
        #
        # @param api_path [String] the API mount path
        # @param format [Symbol] output format (:json, :yaml) - only for data specs
        # @param locale [Symbol, nil] locale for translations (default: nil)
        # @param key_format [Symbol, nil] key casing (:camel, :underscore, :kebab, :keep)
        # @param version [String, nil] spec version (default varies by spec)
        # @return [String] the generated spec
        # @raise [ArgumentError] if format is not supported
        # @see API::Base
        def generate(api_path, format: nil, key_format: nil, locale: nil, version: nil)
          spec = new(api_path, key_format:, locale:, version:)

          raise ArgumentError, "#{spec_name} spec does not support format options" if spec.text_output? && format

          resolved_format = format || :json

          if spec.data_output? && !spec.supports_format?(resolved_format)
            raise ArgumentError, "#{spec_name} spec does not support #{resolved_format} format"
          end

          content = spec.generate
          spec.serialize(content, format: resolved_format)
        end

        # @api public
        # Sets the file extension for text specs.
        #
        # Only valid for specs with `output :text`. Data specs derive
        # their extension from the format (:json → .json, :yaml → .yaml).
        #
        # @param ext [String, nil] the file extension (e.g., '.ts')
        # @return [String, nil] the file extension
        def file_extension(ext = nil)
          return @file_extension unless ext

          raise ConfigurationError, 'file_extension not allowed for output :data specs' if output_type == :data

          @file_extension = ext
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
            next if option.nested?
            next if CORE_OPTIONS_TYPES.key?(name)

            value = source[name] || source[name.to_s]
            next if value.nil?

            result[name] = option.cast(value)
          end

          result
        end

        def extract_options_from_env
          result = {}

          options.each do |name, option|
            next if option.nested?

            env_key = name.to_s.upcase
            value = ENV[env_key]
            next if value.nil?

            result[name] = option.cast(value)
          end

          result
        end
      end

      def initialize(api_path, key_format: nil, locale: nil, version: nil)
        @api_path = api_path
        @api_class = API.find(api_path)
        raise "API not found at path: #{api_path}" unless @api_class

        @options = self.class.default_options
        @options[:key_format] = key_format || @api_class.key_format
        @options[:locale] = locale if locale
        @options[:version] = version if version
        validate_options!

        @data = @api_class.introspect(locale: @options[:locale])
      end

      def validate_options!
        @options.each do |name, value|
          option = self.class.options[name]
          option&.validate!(value)
        end
      end

      # @api public
      # Generates the spec output.
      #
      # Override this method in subclasses to produce the spec format.
      # Access API data via `data` (introspection hash).
      #
      # @return [Hash, String] Hash for data specs, String for text specs
      def generate
        raise NotImplementedError, "#{self.class} must implement #generate"
      end

      def data_output?
        self.class.output_type == :data
      end

      def text_output?
        self.class.output_type == :text
      end

      def supports_format?(format)
        return true if data_output? && %i[json yaml].include?(format)

        false
      end

      def file_extension_for(format: nil)
        resolved = format || :json

        if data_output?
          resolved == :yaml ? '.yaml' : '.json'
        else
          self.class.file_extension
        end
      end

      def content_type_for(format: nil)
        resolved = format || :json

        if data_output?
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

      protected

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

      def metadata
        @data[:metadata]
      end

      def types
        @data[:types] || {}
      end

      def enums
        @data[:enums] || {}
      end

      def resources
        @data[:resources] || {}
      end

      def raises
        @data[:raises] || []
      end

      def error_codes
        @data[:error_codes] || {}
      end

      def each_resource(&block)
        iterate_resources(resources, &block)
      end

      def each_action(resource_data, &block)
        return unless resource_data[:actions]

        resource_data[:actions].each(&block)
      end

      def http_method_for_action(action)
        case action.to_sym
        when :index, :show
          'GET'
        when :create
          'POST'
        when :update
          'PATCH'
        when :destroy
          'DELETE'
        else
          'GET'
        end
      end

      def build_full_resource_path(resource_data, parent_path = nil)
        if parent_path
          "#{parent_path}/#{resource_data[:path]}"
        else
          resource_data[:path]
        end
      end

      def build_full_action_path(resource_data, action_data, parent_path = nil)
        resource_path = build_full_resource_path(resource_data, parent_path)
        "#{resource_path}#{action_data[:path]}"
      end

      private

      def iterate_resources(resources_hash, parent_path = nil, &block)
        resources_hash.each do |resource_name, resource_data|
          yield(resource_name, resource_data, parent_path)

          if resource_data[:resources]
            current_path = build_full_resource_path(resource_data, parent_path)
            iterate_resources(resource_data[:resources], current_path, &block)
          end
        end
      end
    end
  end
end
