# frozen_string_literal: true

module Apiwork
  module Controller
    # Renders JSON responses for different resource types
    #
    # Handles:
    # - Collection responses (with auto-query for index actions)
    # - Single resource responses
    # - Error responses
    # - Delete responses
    #
    # Separated from Controller::Serialization for better separation of concerns
    class ResponseRenderer
      attr_reader :controller, :action_definition, :schema_class, :meta

      def initialize(controller:, action_definition:, schema_class:, meta: {})
        @controller = controller
        @action_definition = action_definition
        @schema_class = schema_class
        @meta = meta
      end

      # Render response for any resource type
      # Follows same pattern as Query#perform for consistency
      def perform(resource_or_collection)
        if resource_or_collection.is_a?(Enumerable)
          build_collection_response(resource_or_collection)
        elsif has_errors?(resource_or_collection)
          build_error_response(resource_or_collection)
        elsif controller.request.delete?
          { ok: true, meta: meta.presence || {} }
        else
          build_single_resource_response(resource_or_collection)
        end
      end

      # Build collection response (with auto-query support)
      def build_collection_response(collection)
        # Auto-query for index action
        query_obj = nil
        if should_auto_query?(collection)
          query_params = extract_query_params
          query_obj = Apiwork::Query.new(collection, schema: schema_class).perform(query_params)
          collection = query_obj.result
        end

        # Serialize data via Schema with validated includes from contract
        includes = extract_includes
        json_data = action_definition.serialize_data(collection, context: build_schema_context, includes: includes)

        # Build complete response with pagination meta
        response = if schema_class
                     root_key = determine_root_key(collection)
                     pagination_meta = query_obj&.meta || {}
                     { ok: true, root_key => json_data, meta: pagination_meta.merge(meta) }
                   else
                     # Custom contract without schema
                     { ok: true }.merge(json_data).merge(meta: meta)
                   end

        # Validate complete response structure
        action_definition.validate_response(response)
      end

      # Build single resource response
      def build_single_resource_response(resource)
        # Serialize data via Schema with validated includes from contract
        includes = extract_includes
        json_data = action_definition.serialize_data(resource, context: build_schema_context, includes: includes)

        # Build complete response
        response = if schema_class
                     root_key = determine_root_key(resource)
                     resp = { ok: true, root_key => json_data }
                     resp[:meta] = meta if meta.present?
                     resp
                   else
                     # Custom contract without schema
                     resp = { ok: true }.merge(json_data)
                     resp[:meta] = meta if meta.present?
                     resp
                   end

        # Validate complete response structure
        action_definition.validate_response(response)
      end

      # Build error response
      def build_error_response(resource)
        if schema_class
          converter = Errors::RailsErrorConverter.new(resource, schema_class: schema_class)
          { ok: false, errors: converter.convert.map(&:to_h) }
        else
          # Without schema, just return basic error structure
          { ok: false, errors: resource.respond_to?(:errors) ? resource.errors.full_messages : [] }
        end
      end

      private

      # Check if resource has errors
      def has_errors?(resource)
        return false unless resource.respond_to?(:errors)

        resource.errors.any?
      end

      # Check if we should auto-query (index action with AR relation and schema)
      def should_auto_query?(resource)
        controller.action_name.to_s == 'index' &&
          resource.is_a?(ActiveRecord::Relation) &&
          schema_class.present?
      end

      # Extract query params from controller
      def extract_query_params
        params = controller.send(:action_params)
        if params.is_a?(ActionController::Parameters)
          params = params.dup.permit!.to_h.deep_symbolize_keys
        elsif params.respond_to?(:to_h)
          params = params.to_h.deep_symbolize_keys
        end

        {
          filter: params[:filter] || {},
          sort: params[:sort],
          page: params[:page] || {},
          include: params[:include]
        }
      end

      # Extract includes parameter
      def extract_includes
        return nil unless controller.params[:include].present?

        includes_hash = controller.params[:include]
        if includes_hash.is_a?(ActionController::Parameters)
          includes_hash = includes_hash.permit!.to_h
        elsif includes_hash.respond_to?(:to_h)
          includes_hash = includes_hash.to_h
        end
        includes_hash.deep_symbolize_keys if includes_hash.respond_to?(:deep_symbolize_keys)
      end

      # Build schema context
      def build_schema_context
        controller.respond_to?(:build_schema_context, true) ? controller.send(:build_schema_context) : {}
      end

      # Determine root key for response
      def determine_root_key(resource_or_collection)
        is_collection = resource_or_collection.is_a?(Enumerable)
        root_key = schema_class.root_key
        is_collection ? root_key.plural : root_key.singular
      end
    end
  end
end
