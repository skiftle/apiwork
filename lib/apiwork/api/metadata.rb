# frozen_string_literal: true

module Apiwork
  module API
    class Metadata
      attr_reader :concerns,
                  :namespaces,
                  :path,
                  :resources

      attr_accessor :error_codes,
                    :info

      def initialize(path)
        @path = path

        @namespaces = path == '/' ? [] : path.split('/').reject(&:empty?).map(&:to_sym)

        @resources = {}
        @concerns = {}
        @info = nil
        @error_codes = []
      end

      def add_resource(name, singular:, contract:, controller: nil, parent: nil, **options)
        target = if parent
                   parent_resource = find_resource(parent)
                   return unless parent_resource

                   parent_resource[:resources] ||= {}
                 else
                   @resources
                 end

        target[name] = {
          singular: singular,
          contract: contract,
          contract_class: nil,
          controller: controller,
          actions: {},
          only: determine_actions(singular, options),
          members: {},
          collections: {},
          resources: {},
          parent: parent,
          options: options,
          metadata: {}
        }
      end

      def resolve_contract_class(resource_data)
        return resource_data[:contract_class] if resource_data[:contract_class]
        return nil unless resource_data[:contract]

        resource_data[:contract_class] = resource_data[:contract].constantize
      rescue NameError
        nil
      end

      def add_crud_action(resource_name, action, method:, metadata: {})
        resource = find_resource(resource_name)
        return unless resource

        resource[:actions][action] = {
          method: method,
          metadata: metadata
        }
      end

      def add_action(resource_name, action, type:, method:, options:, contract_class: nil, metadata: {})
        resource = find_resource(resource_name)
        return unless resource

        storage_key = type == :member ? :members : :collections
        resource[storage_key][action] = {
          method: method,
          options: options,
          contract_class: contract_class,
          metadata: metadata
        }
      end

      def add_concern(name, block)
        @concerns[name] = block
      end

      def find_resource(resource_name)
        return resources[resource_name] if resources[resource_name]

        resources.each_value do |resource_metadata|
          found = find_resource_recursive(resource_metadata, resource_name)
          return found if found
        end

        nil
      end

      def search_resources(&block)
        resources.each_value do |resource_metadata|
          result = search_in_resource_tree(resource_metadata, &block)
          return result if result
        end

        nil
      end

      private

      def find_resource_recursive(resource_metadata, resource_name)
        return resource_metadata[:resources][resource_name] if resource_metadata[:resources]&.key?(resource_name)

        resource_metadata[:resources]&.each_value do |nested_metadata|
          found = find_resource_recursive(nested_metadata, resource_name)
          return found if found
        end

        nil
      end

      def search_in_resource_tree(resource_metadata, &block)
        result = yield(resource_metadata)
        return result if result

        resource_metadata[:resources]&.each_value do |nested_metadata|
          result = search_in_resource_tree(nested_metadata, &block)
          return result if result
        end

        nil
      end

      def determine_actions(singular, options)
        only = options[:only]
        except = options[:except]

        if only
          Array(only).map(&:to_sym)
        else
          default_actions = if singular
                              [:show, :create, :update, :destroy]
                            else
                              [:index, :show, :create, :update, :destroy]
                            end

          if except
            default_actions - Array(except).map(&:to_sym)
          else
            default_actions
          end
        end
      end
    end
  end
end
