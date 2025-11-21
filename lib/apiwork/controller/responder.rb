# frozen_string_literal: true

module Apiwork
  module Controller
    class Responder
      attr_reader :controller, :action_definition, :schema_class, :meta

      def initialize(controller:, action_definition:, schema_class:, meta: {})
        @controller = controller
        @action_definition = action_definition
        @schema_class = schema_class
        @meta = meta
      end

      def perform(resource_or_collection, query_params: {})
        if resource_or_collection.is_a?(Enumerable)
          return build_collection_response(resource_or_collection,
                                           query_params)
        end

        if resource_or_collection.respond_to?(:errors) && resource_or_collection.errors.any?
          adapter = ValidationAdapter.new(resource_or_collection, schema_class: schema_class)
          issues = adapter.convert
          raise ValidationError, issues
        end

        build_single_resource_response(resource_or_collection, query_params)
      end

      def build_collection_response(collection, query_params)
        includes_param = extract_includes_param(query_params)

        query_obj = nil
        if controller.action_name.to_s == 'index' && collection.is_a?(ActiveRecord::Relation) && schema_class.present?
          query_obj = Apiwork::Query.new(collection, schema: schema_class).perform(query_params)
          collection = query_obj.result
        end

        json_data = action_definition.serialize_data(collection, context: build_schema_context,
                                                                 includes: includes_param)

        if schema_class
          root_key = determine_root_key(collection)
          pagination_meta = controller.action_name.to_s == 'index' ? (query_obj&.meta || {}) : {}
          combined_meta = pagination_meta.merge(meta)
          resp = { ok: true, root_key => json_data }
          resp[:meta] = combined_meta if combined_meta.present?
          resp
        else
          { ok: true }.merge(json_data).merge(meta: meta)
        end
      end

      def build_single_resource_response(resource, query_params = {})
        includes_param = extract_includes_param(query_params)

        if resource.is_a?(ActiveRecord::Base) && resource.persisted? && schema_class.present?
          includes_hash = build_includes_hash_for_eager_loading(includes_param)
          resource = reload_with_includes(resource, includes_hash) if includes_hash.any?
        end

        json_data = action_definition.serialize_data(resource, context: build_schema_context, includes: includes_param)

        if action_definition.schema_class
          return { ok: true, meta: meta.presence || {} } if controller.request.delete?

          root_key = determine_root_key(resource)
          resp = { ok: true, root_key => json_data }
        else
          resp = { ok: true }.merge(json_data)
        end

        resp[:meta] = meta if meta.present?
        resp
      end

      private

      def extract_includes_param(query_params)
        includes = query_params[:include] || controller.params[:include]
        return nil if includes.blank?

        includes = includes.permit!.to_h if includes.is_a?(ActionController::Parameters)
        includes = includes.to_h if includes.respond_to?(:to_h)
        includes.deep_symbolize_keys if includes.respond_to?(:deep_symbolize_keys)
      end

      def build_includes_hash_for_eager_loading(includes_param)
        return {} if includes_param.blank?

        Query::IncludesResolver.new(schema: schema_class).build(
          params: { include: includes_param },
          for_collection: false
        )
      end

      def reload_with_includes(resource, includes_hash)
        resource.class.includes(includes_hash).find(resource.id)
      end

      def build_schema_context
        controller.respond_to?(:build_schema_context, true) ? controller.send(:build_schema_context) : {}
      end

      def determine_root_key(resource_or_collection)
        root_key = schema_class.root_key
        resource_or_collection.is_a?(Enumerable) ? root_key.plural : root_key.singular
      end
    end
  end
end
