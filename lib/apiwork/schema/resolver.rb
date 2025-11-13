# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Schema
    class Resolver
      # Thread-safe cache for resolved schema classes
      @cache = Concurrent::Map.new

      class << self
        def from_model(model_class_or_instance, namespace: nil)
          model_class = extract_model_class(model_class_or_instance)

          cache_key = cache_key_for_model(model_class, namespace)

          @cache.fetch_or_store(cache_key) do
            if namespace
              # Explicit namespace provided - use it
              resolve_schema_class("#{namespace}::#{model_class.model_name}Schema")
            else
              # No namespace - try root level (global scope)
              # Example: Client → ClientSchema (not Api::V1::ClientSchema)
              resolve_schema_class("#{model_class.model_name}Schema")
            end
          end
        end

        def from_controller(controller_class)
          namespace = extract_namespace_from_controller(controller_class)
          schema_name = extract_schema_name_from_controller(controller_class)

          cache_key = "controller:#{controller_class.name}"

          @cache.fetch_or_store(cache_key) do
            if namespace.present?
              # Controller has namespace (e.g., Api::V1::ClientsController)
              resolve_schema_class("#{namespace}::#{schema_name}Schema")
            else
              # Controller at root level (e.g., ClientsController)
              resolve_schema_class("#{schema_name}Schema")
            end
          end
        end

        def from_association(reflection, base_schema_class)
          return nil unless reflection
          return nil if reflection.polymorphic?

          associated_model = reflection.klass
          namespace = base_schema_class.name.deconstantize

          cache_key = "association:#{namespace}:#{associated_model.name}"

          @cache.fetch_or_store(cache_key) do
            schema_class_name = "#{namespace}::#{associated_model.name}Schema"
            schema_class_name.safe_constantize
          end
        end

        def from_scope(scope_or_collection, namespace: nil)
          model_class = if scope_or_collection.respond_to?(:klass)
                          # ActiveRecord::Relation
                          scope_or_collection.klass
                        elsif scope_or_collection.respond_to?(:model_name)
                          # ActiveRecord instance
                          scope_or_collection.class
                        else
                          # Fallback
                          scope_or_collection.class
                        end

          from_model(model_class, namespace: namespace)
        end

        def clear_cache!
          @cache.clear
        end

        private

        # Extract model class from class or instance
        def extract_model_class(model_class_or_instance)
          if model_class_or_instance.is_a?(Class)
            model_class_or_instance
          else
            model_class_or_instance.class
          end
        end

        # Build cache key for model-based lookup
        def cache_key_for_model(model_class, namespace)
          "model:#{namespace}:#{model_class.name}"
        end

        # Extract namespace from controller class path
        # Api::V1::ClientsController => "Api::V1"
        def extract_namespace_from_controller(controller_class)
          controller_class.name.deconstantize
        end

        # Extract schema name from controller class
        # Api::V1::ClientsController => "Client"
        def extract_schema_name_from_controller(controller_class)
          controller_class.name.demodulize.sub(/Controller$/, '').singularize
        end

        # Resolve schema class name to actual class
        def resolve_schema_class(class_name)
          class_name.constantize
        rescue NameError => e
          raise Apiwork::ConfigurationError,
                "Could not find Schema class '#{class_name}'. " \
                'Make sure the schema exists and follows the naming convention. ' \
                "Error: #{e.message}"
        end
      end
    end
  end
end
