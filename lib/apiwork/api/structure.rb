# frozen_string_literal: true

module Apiwork
  module API
    class Structure
      attr_reader :namespaces,
                  :path,
                  :resources
      attr_accessor :info,
                    :raises

      def initialize(path)
        @path = path
        @namespaces = extract_namespaces(path)
        @resources = {}
        @info = nil
        @raises = []
      end

      def locale_key
        @locale_key ||= path.delete_prefix('/')
      end

      def i18n_lookup(*segments, default: nil)
        key = :"apiwork.apis.#{locale_key}.#{segments.join('.')}"
        I18n.t(key, default:)
      end

      def has_resources?
        @resources.any?
      end

      def has_index_actions?
        @resources.values.any?(&:has_index?)
      end

      def schemas
        @schemas ||= collect_all_schemas
      end

      def add_resource(resource)
        @resources[resource.name] = resource
      end

      def find_resource(resource_name)
        return @resources[resource_name] if @resources[resource_name]

        @resources.each_value do |resource|
          found = resource.find_resource(resource_name)
          return found if found
        end

        nil
      end

      def each_resource(&block)
        @resources.each_value do |resource|
          yield resource
          resource.each_resource(&block)
        end
      end

      def search_resources(&block)
        @resources.each_value do |resource|
          result = search_in_resource_tree(resource, &block)
          return result if result
        end

        nil
      end

      private

      def extract_namespaces(path)
        return [] if path == '/'

        path.split('/').reject(&:empty?).map { |n| n.tr('-', '_').to_sym }
      end

      def collect_all_schemas
        schemas = []
        each_resource do |resource|
          schema = resource.schema
          schemas << schema if schema
        end
        schemas
      end

      def search_in_resource_tree(resource, &block)
        result = yield(resource)
        return result if result

        resource.resources.each_value do |nested_resource|
          result = search_in_resource_tree(nested_resource, &block)
          return result if result
        end

        nil
      end
    end
  end
end
