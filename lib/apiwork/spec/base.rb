# frozen_string_literal: true

module Apiwork
  module Spec
    # @api public
    # Base class for spec generators.
    #
    # Subclass this to create custom spec formats. Declare output type
    # and override `#generate` to produce output.
    #
    # @example Hash spec (supports json/yaml)
    #   class OpenAPISpec < Apiwork::Spec::Base
    #     spec_name :openapi
    #     output :hash
    #
    #     def generate
    #       { openapi: '3.1.0', ... }  # Returns Hash
    #     end
    #   end
    #
    # @example String spec (fixed format)
    #   class ProtobufSpec < Apiwork::Spec::Base
    #     spec_name :protobuf
    #     output :string
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
        # @param type [Symbol] :hash for Hash output (json/yaml), :string for String output
        def output(type = nil)
          return @output_type unless type

          raise ArgumentError, "output must be :hash or :string, got #{type.inspect}" unless %i[hash string].include?(type)

          @output_type = type
        end

        attr_reader :output_type

        def generate(api_path, format: nil, key_format: nil, locale: nil, version: nil)
          spec = new(api_path, key_format:, locale:, version:)

          raise ArgumentError, "#{spec_name} spec does not support format options" if spec.string_output? && format

          resolved_format = format || :json

          if spec.hash_output? && !spec.supports_format?(resolved_format)
            raise ArgumentError, "#{spec_name} spec does not support #{resolved_format} format"
          end

          content = spec.generate
          spec.serialize(content, format: resolved_format)
        end

        # @api public
        # Sets the file extension for string specs.
        #
        # Only valid for specs with `output :string`. Hash specs derive
        # their extension from the format (:json → .json, :yaml → .yaml).
        #
        # @param file_extension [String, nil] the file extension (e.g., '.ts')
        # @return [String, nil] the file extension
        def file_extension(file_extension = nil)
          return @file_extension unless file_extension

          raise ConfigurationError, 'file_extension not allowed for output :hash specs' if output_type == :hash

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
      # Generates the spec output.
      #
      # Override this method in subclasses to produce the spec format.
      # Access API data via helper methods: {#types}, {#enums}, {#raises},
      # {#error_codes}, {#info}, {#each_resource}, {#each_action}.
      #
      # @return [Hash, String] Hash for hash specs, String for string specs
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
      # Returns the data wrapper for introspection data.
      #
      # This is the primary interface for accessing introspection data in spec generators.
      # Use this instead of accessing raw hash data directly.
      #
      # @return [Spec::Data]
      # @see Spec::Data
      def data
        @data ||= Data.new(@introspection)
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

      # @api public
      # Returns API metadata.
      #
      # @return [Hash] API info with structure:
      #   - :title [String] API title
      #   - :version [String] API version
      #   - :description [String] API description
      #   - :contact [Hash] contact info (:name, :email, :url)
      #   - :license [Hash] license info (:name, :url)
      #   - :servers [Array<Hash>] server URLs
      #   - :summary [String] short summary
      #   - :terms_of_service [String] ToS URL
      def info
        @introspection[:info] || {}
      end

      # @api public
      # Returns all registered custom types.
      #
      # @return [Hash{Symbol => Hash}] type definitions with structure:
      #   - :type [Symbol] :object or :union
      #   - :shape [Hash] param definitions (for objects)
      #   - :variants [Array<Hash>] union variants
      #   - :discriminator [Symbol] union discriminator field
      #   - :description [String] type description
      #   - :example [Object] example value
      #   - :deprecated [Boolean] deprecation flag
      def types
        @introspection[:types] || {}
      end

      # @api public
      # Returns all registered enums.
      #
      # @return [Hash{Symbol => Hash}] enum definitions with structure:
      #   - :values [Array<String>] allowed values
      #   - :description [String] enum description
      #   - :example [String] example value
      #   - :deprecated [Boolean] deprecation flag
      def enums
        @introspection[:enums] || {}
      end

      # @api public
      # Returns API-level error codes that may be raised.
      #
      # @return [Array<Symbol>] error code keys (e.g., [:unauthorized, :not_found])
      def raises
        @introspection[:raises] || []
      end

      # @api public
      # Returns detailed error code information.
      #
      # @return [Hash{Symbol => Hash}] error codes with structure:
      #   - :status [Integer] HTTP status code
      #   - :description [String] error description
      def error_codes
        @introspection[:error_codes] || {}
      end

      # @api public
      # Iterates over all resources recursively (including nested).
      #
      # @yieldparam name [Symbol] resource name
      # @yieldparam data [Hash] resource data with structure:
      #   - :identifier [String] resource identifier
      #   - :path [String] URL path segment
      #   - :actions [Hash{Symbol => Hash}] action definitions
      #   - :resources [Hash] nested resources (optional)
      # @yieldparam parent_path [String, nil] parent resource path
      def each_resource(&block)
        iterate_resources(resources, &block)
      end

      # @api public
      # Iterates over actions in a resource.
      #
      # @param resource_data [Hash] resource data
      # @yieldparam action_name [Symbol] action name (:index, :show, etc.)
      # @yieldparam action_data [Hash] action data with structure:
      #   - :path [String] action path (e.g., "/:id")
      #   - :method [Symbol] HTTP method (:get, :post, etc.)
      #   - :request [Hash] request definition (optional)
      #   - :response [Hash] response definition (optional)
      #   - :raises [Array<Symbol>] error codes (optional)
      #   - :tags [Array<String>] OpenAPI tags (optional)
      #   - :summary [String] short description (optional)
      #   - :description [String] full description (optional)
      #   - :deprecated [Boolean] deprecation flag (optional)
      def each_action(resource_data, &block)
        return unless resource_data[:actions]

        resource_data[:actions].each(&block)
      end

      # @api public
      # Builds the full URL path for a resource.
      #
      # @param resource_data [Hash] resource data
      # @param parent_path [String, nil] parent resource path
      # @return [String] full resource path (e.g., "users/:user_id/posts")
      def build_full_resource_path(resource_data, parent_path = nil)
        if parent_path
          "#{parent_path}/#{resource_data[:path]}"
        else
          resource_data[:path]
        end
      end

      # @api public
      # Builds the full URL path for an action.
      #
      # @param resource_data [Hash] resource data
      # @param action_data [Hash] action data
      # @param parent_path [String, nil] parent resource path
      # @return [String] full action path (e.g., "users/:user_id/posts/:id")
      def build_full_action_path(resource_data, action_data, parent_path = nil)
        resource_path = build_full_resource_path(resource_data, parent_path)
        "#{resource_path}#{action_data[:path]}"
      end

      private

      def resources
        @introspection[:resources] || {}
      end

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
