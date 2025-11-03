# frozen_string_literal: true

module Apiwork
  module Controller
    # Handles resource serialization and response building
    #
    # Provides:
    # - serialize_resource - Serializes objects using Resource class
    # - respond_with - Unified response builder for all actions
    #
    module Serialization
      extend ActiveSupport::Concern

      def serialize_resource(object_or_collection, resource_class: nil)
        resource_class ||= Resource::Resolver.from_scope(object_or_collection, namespace: self.class.name.deconstantize)
        resource_class.serialize(object_or_collection, build_resource_context)
      end

      def respond_with(resource_or_collection, options = {})
        meta = options.fetch(:meta, {})

        # Find ActionDefinition for current action
        action_def = find_action_definition
        raise ConfigurationError, "No contract found for #{self.class.name}##{action_name}" unless action_def

        # Get resource class from contract (may be nil for custom contracts)
        resource_class = action_def.contract_class.resource_class

        # Transform meta keys if resource exists
        if meta.present? && resource_class
          meta_key_transform = resource_class.serialize_key_transform
          meta = Apiwork::Transform::Case.hash(meta, meta_key_transform)
        end

        # Build response through action definition
        response_data = build_response_data(resource_or_collection, action_def, resource_class, meta)

        render json: response_data, status: determine_status(resource_or_collection)
      end

      private

      # Find ActionDefinition for current action
      def find_action_definition
        Contract::Resolver.resolve(self.class, action_name.to_sym)
      end

      def build_response_data(resource_or_collection, action_def, resource_class, meta)
        if resource_or_collection.is_a?(Enumerable)
          build_collection_response(resource_or_collection, action_def, resource_class, meta)
        elsif has_errors?(resource_or_collection)
          build_error_response(resource_or_collection, action_def, resource_class)
        elsif request.delete?
          { ok: true, meta: meta.presence || {} }
        else
          build_single_resource_response(resource_or_collection, action_def, resource_class, meta)
        end
      end

      def build_collection_response(collection, action_def, resource_class, meta)
        # Serialize data via Resource
        json_data = action_def.serialize_data(collection, context: build_resource_context)

        # Build complete response with pagination meta
        if resource_class
          root_key = determine_root_key(resource_class, collection)
          pagination_meta = resource_class.build_meta(collection)
          response = { ok: true, root_key => json_data, meta: pagination_meta.merge(meta) }
        else
          # Custom contract without resource
          response = { ok: true }.merge(json_data).merge(meta: meta)
        end

        # Validate complete response structure
        action_def.validate_response(response)
      end

      def build_error_response(resource, _action_def, resource_class)
        if resource_class
          converter = Errors::RailsErrorConverter.new(resource, resource_class:)
          { ok: false, errors: converter.convert.map(&:to_h) }
        else
          # Without resource, just return basic error structure
          { ok: false, errors: resource.respond_to?(:errors) ? resource.errors.full_messages : [] }
        end
      end

      def build_single_resource_response(resource, action_def, resource_class, meta)
        # Serialize data via Resource
        json_data = action_def.serialize_data(resource, context: build_resource_context)

        # Build complete response
        if resource_class
          root_key = determine_root_key(resource_class, resource)
          response = { ok: true, root_key => json_data }
          response[:meta] = meta if meta.present?
        else
          # Custom contract without resource
          response = { ok: true }.merge(json_data)
          response[:meta] = meta if meta.present?
        end

        # Validate complete response structure
        action_def.validate_response(response)
      end

      def has_errors?(resource)
        resource.respond_to?(:errors) && resource.errors.any?
      end

      def determine_status(resource_or_collection)
        if has_errors?(resource_or_collection)
          :unprocessable_content
        elsif request.delete?
          :ok
        elsif request.post?
          :created
        else
          :ok
        end
      end

      def build_resource_context
        {}
      end

      def determine_root_key(resource_class, resource_or_collection)
        is_collection = resource_or_collection.is_a?(Enumerable)
        root_key = resource_class.root_key
        is_collection ? root_key.plural : root_key.singular
      end
    end
  end
end
