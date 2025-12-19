# frozen_string_literal: true

module Apiwork
  module Spec
    # @api private
    class Base
      include Registrable
      include Configurable

      option :locale, type: :symbol, default: nil

      attr_reader :api_path,
                  :data,
                  :options

      class << self
        def generate(api_path, **options)
          new(api_path, **options).generate
        end

        def content_type(type = nil)
          @content_type = type if type
          @content_type || 'application/json'
        end

        def file_extension
          raise NotImplementedError, "#{self} must implement .file_extension"
        end
      end

      def initialize(api_path, **options)
        @api_path = api_path
        @api_class = Apiwork::API.find(api_path)
        raise "API not found at path: #{api_path}" unless @api_class

        @options = self.class.default_options
                       .merge(key_format: @api_class.key_format)
                       .merge(options)
        validate_options!

        @data = @api_class.introspect(locale: @options[:locale])
      end

      def validate_options!
        @options.each do |name, value|
          option = self.class.options[name]
          option&.validate!(value)
        end
      end

      def generate
        raise NotImplementedError, "#{self.class} must implement #generate"
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

        transform = lambda do |s|
          case strategy
          when :camel then s.camelize(:lower)
          when :underscore then s.underscore
          else s
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
