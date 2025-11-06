# frozen_string_literal: true

module Apiwork
  module Controller
    # Handles schema serialization and response building
    #
    # Provides:
    # - serialize_schema - Serializes objects using Schema class
    # - respond_with - Unified response builder for all actions
    #
    module Serialization
      extend ActiveSupport::Concern

      def serialize_schema(object_or_collection, schema_class: nil)
        schema_class ||= Schema::Resolver.from_scope(object_or_collection, namespace: self.class.name.deconstantize)
        schema_class.serialize(object_or_collection, context: build_schema_context)
      end

      def respond_with(resource_or_collection, options = {})
        meta = options.fetch(:meta, {})
        contract_class_name = options[:contract_class_name]

        # Find ActionDefinition for current action
        action_def = if contract_class_name
          contract = contract_class_name.constantize
          contract.action_definition(action_name.to_sym)
        else
          find_action_definition
        end

        raise ConfigurationError, "No contract found for #{self.class.name}##{action_name}" unless action_def

        # Get schema class from contract (may be nil for custom contracts)
        schema_class = action_def.contract_class.schema_class

        # Transform meta keys if schema exists
        if meta.present? && schema_class
          meta_key_transform = schema_class.serialize_key_transform
          meta = Apiwork::Transform::Case.hash(meta, meta_key_transform)
        end

        # Build response through action definition
        response_data = build_response_data(resource_or_collection, action_def, schema_class, meta)

        render json: response_data, status: determine_status(resource_or_collection)
      end

      private

      # Find ActionDefinition for current action
      def find_action_definition
        metadata = find_action_metadata
        Contract::Resolver.resolve(self.class, action_name.to_sym, metadata: metadata)
      end

      def build_response_data(resource_or_collection, action_def, schema_class, meta)
        if resource_or_collection.is_a?(Enumerable)
          build_collection_response(resource_or_collection, action_def, schema_class, meta)
        elsif has_errors?(resource_or_collection)
          build_error_response(resource_or_collection, action_def, schema_class)
        elsif request.delete?
          { ok: true, meta: meta.presence || {} }
        else
          build_single_resource_response(resource_or_collection, action_def, schema_class, meta)
        end
      end

      def build_collection_response(collection, action_def, schema_class, meta)
        # Serialize data via Schema with validated includes from contract
        includes = extract_includes
        json_data = action_def.serialize_data(collection, context: build_schema_context, includes: includes)

        # Build complete response with pagination meta
        if schema_class
          root_key = determine_root_key(schema_class, collection)
          pagination_meta = schema_class.build_meta(collection)
          response = { ok: true, root_key => json_data, meta: pagination_meta.merge(meta) }
        else
          # Custom contract without schema
          response = { ok: true }.merge(json_data).merge(meta: meta)
        end

        # Validate complete response structure
        action_def.validate_response(response)
      end

      def build_error_response(resource, _action_def, schema_class)
        if schema_class
          converter = Errors::RailsErrorConverter.new(resource, schema_class:)
          { ok: false, errors: converter.convert.map(&:to_h) }
        else
          # Without schema, just return basic error structure
          { ok: false, errors: resource.respond_to?(:errors) ? resource.errors.full_messages : [] }
        end
      end

      def build_single_resource_response(resource, action_def, schema_class, meta)
        # Serialize data via Schema with validated includes from contract
        includes = extract_includes
        json_data = action_def.serialize_data(resource, context: build_schema_context, includes: includes)

        # Build complete response
        if schema_class
          root_key = determine_root_key(schema_class, resource)
          response = { ok: true, root_key => json_data }
          response[:meta] = meta if meta.present?
        else
          # Custom contract without schema
          response = { ok: true }.merge(json_data)
          response[:meta] = meta if meta.present?
        end

        # Validate complete response structure
        action_def.validate_response(response)
      end

      def has_errors?(resource)
        return false unless resource.respond_to?(:errors)

        resource.errors.any?
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

      def build_schema_context
        {}
      end

      # Extract includes parameter (already validated by Contract)
      def extract_includes
        return nil unless params[:include].present?

        # Extract validated includes from params
        includes_hash = params[:include]
        if includes_hash.is_a?(ActionController::Parameters)
          includes_hash = includes_hash.permit!.to_h
        elsif includes_hash.respond_to?(:to_h)
          includes_hash = includes_hash.to_h
        end
        includes_hash.deep_symbolize_keys if includes_hash.respond_to?(:deep_symbolize_keys)
      end

      def determine_root_key(schema_class, resource_or_collection)
        is_collection = resource_or_collection.is_a?(Enumerable)
        root_key = schema_class.root_key
        is_collection ? root_key.plural : root_key.singular
      end
    end
  end
end
