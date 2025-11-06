# frozen_string_literal: true

require 'concurrent/map'

module Apiwork
  module Schema
    # Centralized service for resolving Resource classes from various contexts.
    # Handles auto-discovery with caching and namespace detection.
    #
    # @example Finding resource from model
    #   Schema::Resolver.from_model(Client) # => Api::V1::ClientSchema
    #
    # @example Finding resource from controller
    #   Schema::Resolver.from_controller(Api::V1::ClientsController) # => Api::V1::ClientSchema
    #
    # @example Finding resource from association
    #   reflection = Client.reflect_on_association(:projects)
    #   Schema::Resolver.from_association(reflection, ClientSchema) # => Api::V1::ProjectSchema
    #
    class Resolver
      # Thread-safe cache for resolved resource classes
      @cache = Concurrent::Map.new

      class << self
        # Find Resource class from a model class or instance
        #
        # @param model_class_or_instance [Class, ActiveRecord::Base] Model class or instance
        # @param namespace [String, nil] Optional namespace override (e.g., "Api::V1")
        # @return [Class] Resource class
        # @raise [ConfigurationError] If resource class cannot be found
        #
        def from_model(model_class_or_instance, namespace: nil)
          model_class = extract_model_class(model_class_or_instance)

          cache_key = cache_key_for_model(model_class, namespace)

          @cache.fetch_or_store(cache_key) do
            if namespace
              # Explicit namespace provided - use it
              resolve_resource_class("#{namespace}::#{model_class.model_name}Schema")
            else
              # No namespace - try root level (global scope)
              # Example: Client → ClientSchema (not Api::V1::ClientSchema)
              resolve_resource_class("#{model_class.model_name}Schema")
            end
          end
        end

        # Find Resource class from a controller class
        #
        # @param controller_class [Class] Controller class
        # @return [Class] Resource class
        # @raise [ConfigurationError] If resource class cannot be found
        #
        def from_controller(controller_class)
          namespace = extract_namespace_from_controller(controller_class)
          resource_name = extract_resource_name_from_controller(controller_class)

          cache_key = "controller:#{controller_class.name}"

          @cache.fetch_or_store(cache_key) do
            if namespace.present?
              # Controller has namespace (e.g., Api::V1::ClientsController)
              resolve_resource_class("#{namespace}::#{resource_name}Schema")
            else
              # Controller at root level (e.g., ClientsController)
              resolve_resource_class("#{resource_name}Schema")
            end
          end
        end

        # Find Resource class from an ActiveRecord association reflection
        #
        # @param reflection [ActiveRecord::Reflection] Association reflection
        # @param base_resource_class [Class] Base resource class (used for namespace detection)
        # @return [Class, nil] Resource class or nil if not found
        #
        def from_association(reflection, base_resource_class)
          return nil unless reflection
          return nil if reflection.polymorphic?

          associated_model = reflection.klass
          namespace = base_resource_class.name.deconstantize

          cache_key = "association:#{namespace}:#{associated_model.name}"

          @cache.fetch_or_store(cache_key) do
            resource_class_name = "#{namespace}::#{associated_model.name}Schema"
            resource_class_name.safe_constantize
          end
        end

        # Find Resource class from scope or collection
        #
        # @param scope_or_collection [ActiveRecord::Relation, ActiveRecord::Base, Array] Scope or object
        # @param namespace [String, nil] Optional namespace override
        # @return [Class] Resource class
        # @raise [ConfigurationError] If resource class cannot be found
        #
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

        # Find Contract class for a specific controller action
        #
        # @param controller_class [Class] Controller class
        # @param action_name [String, Symbol] Action name
        # @return [Class, nil] Contract class, or nil if not found
        #
        def contract_for_action(controller_class, action_name)
          namespace = extract_namespace_from_controller(controller_class)
          controller_base_name = controller_class.name.demodulize.sub(/Controller$/, '').singularize
          action_name_camelized = action_name.to_s.camelize

          cache_key = "contract:#{controller_class.name}:#{action_name}"

          @cache.fetch_or_store(cache_key) do
            contract_class_name = "#{namespace}::#{controller_base_name}#{action_name_camelized}Contract"
            begin
              contract_class_name.constantize
            rescue NameError
              nil
            end
          end
        end

        # Clear the cache (useful for testing and development)
        #
        # @return [void]
        #
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

        # Extract resource name from controller class
        # Api::V1::ClientsController => "Client"
        def extract_resource_name_from_controller(controller_class)
          controller_class.name.demodulize.sub(/Controller$/, '').singularize
        end

        # Resolve resource class name to actual class
        def resolve_resource_class(class_name)
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
