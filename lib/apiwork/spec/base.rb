# frozen_string_literal: true

module Apiwork
  module Spec
    class Base
      include Registrable
      include Configurable

      attr_reader :data,
                  :options,
                  :path

      class << self
        def generate(path:, **options)
          new(path, **options).generate
        end

        def content_type(type = nil)
          @content_type = type if type
          @content_type || 'application/json'
        end

        def file_extension
          raise NotImplementedError, "#{self} must implement .file_extension"
        end
      end

      def initialize(path, **options)
        @path = path
        @options = self.class.default_options.merge(options)
        validate_options!
        load_data
      end

      def validate_options!
        @options.each do |name, value|
          option = self.class.options[name]
          option&.validate!(value)
        end
      end

      def load_data
        api = Apiwork::API.find(path)
        raise "API not found at path: #{path}" unless api

        @data = api.introspect
      end

      def generate
        raise NotImplementedError, "#{self.class} must implement #generate"
      end

      protected

      def key_transform
        @options[:key_transform]
      end

      def version
        @options[:version]
      end

      def transform_key(key, strategy = nil)
        key_str = key.to_s
        transform_strategy = strategy || key_transform

        if key_str.start_with?('_')
          underscore_prefix = key_str.match(/^_+/)[0]
          key_without_prefix = key_str[underscore_prefix.length..]
          transformed = transform_string(key_without_prefix, transform_strategy)
          "#{underscore_prefix}#{transformed}"
        else
          transform_string(key_str, transform_strategy)
        end
      end

      def transform_string(string, strategy)
        string_value = string.to_s
        case strategy
        when :camel
          string_value.camelize(:lower)
        when :underscore
          string_value.underscore
        else
          string_value
        end
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

      def error_codes
        @data[:error_codes] || []
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
