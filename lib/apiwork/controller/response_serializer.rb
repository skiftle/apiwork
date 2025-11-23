# frozen_string_literal: true

module Apiwork
  module Controller
    class ResponseSerializer
      attr_reader :action_definition,
                  :schema_class

      def initialize(contract_class, action, method)
        @contract_class = contract_class
        @action = action.to_sym
        @method = method.to_sym
        @action_definition = contract_class.action_definition(action)
        @schema_class = @action_definition&.schema_class
      end

      def perform(resource_or_collection, request:, meta: {}, context: {})
        @meta = @contract_class.format_keys(meta, :response)
        @context = context
        @request = request

        return collection_response(resource_or_collection) if resource_or_collection.is_a?(Enumerable)

        if resource_or_collection.respond_to?(:errors) && resource_or_collection.errors.any?
          adapter = ValidationAdapter.new(resource_or_collection, schema_class: schema_class)
          issues = adapter.convert
          raise ValidationError, issues
        end

        resource_response(resource_or_collection)
      end

      def collection_response(collection)
        includes_param = @request.data[:include]

        query_result = nil
        if @action == :index && collection.is_a?(ActiveRecord::Relation) && schema_class.present?
          query_result = Apiwork::Query.new(collection, schema: schema_class).perform(@request.data)
          filtered_collection = query_result.result
        else
          filtered_collection = collection
        end

        serialized_data = action_definition.serialize_data(filtered_collection,
                                                           context: @context,
                                                           includes: includes_param)

        if schema_class
          root_key_value = root_key(filtered_collection)
          pagination_meta = @action == :index ? (query_result&.meta || {}) : {}
          combined_meta = pagination_meta.merge(@meta)
          response = { ok: true, root_key_value => serialized_data }
          response[:meta] = combined_meta if combined_meta.present?
          response
        else
          { ok: true }.merge(serialized_data).merge(meta: @meta)
        end
      end

      def resource_response(resource)
        includes_param = @request.data[:include]

        if resource.is_a?(ActiveRecord::Base) && resource.persisted? && schema_class.present?
          includes_hash_value = includes_hash(includes_param)
          resource = reload_with_includes(resource, includes_hash_value) if includes_hash_value.any?
        end

        serialized_data = action_definition.serialize_data(resource, context: @context, includes: includes_param)

        if schema_class
          return { ok: true, meta: @meta.presence || {} } if @method == :delete

          root_key_value = root_key(resource)
          response = { ok: true, root_key_value => serialized_data }
        else
          response = { ok: true }.merge(serialized_data)
        end

        response[:meta] = @meta if @meta.present?
        response
      end

      private

      def includes_hash(includes_param)
        return {} if includes_param.blank?

        Query::IncludesResolver.new(schema: schema_class).build(
          params: { include: includes_param },
          for_collection: false
        )
      end

      def reload_with_includes(resource, includes_hash_value)
        resource.class.includes(includes_hash_value).find(resource.id)
      end

      def root_key(resource_or_collection)
        root_key_object = schema_class.root_key
        resource_or_collection.is_a?(Enumerable) ? root_key_object.plural : root_key_object.singular
      end
    end
  end
end
