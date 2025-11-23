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
          validation_adapter = ValidationAdapter.new(resource_or_collection, schema_class: schema_class)
          issues = validation_adapter.convert
          raise ValidationError, issues
        end

        resource_response(resource_or_collection)
      end

      def collection_response(collection)
        includes_param = @request.data[:include]
        adapter_instance = adapter
        render_meta = render_metadata

        query_result = nil
        if schema_class.present?
          scoped_collection = adapter_instance.collection_scope(
            collection,
            schema_data,
            @request.data,
            render_meta
          )

          if scoped_collection.respond_to?(:result) && scoped_collection.respond_to?(:meta)
            query_result = scoped_collection
            filtered_collection = query_result.result
          else
            filtered_collection = scoped_collection
          end
        else
          filtered_collection = collection
        end

        serialized_data = action_definition.serialize_data(filtered_collection,
                                                           context: @context,
                                                           includes: includes_param)

        if schema_class
          pagination_meta = query_result&.meta || {}
          combined_meta = pagination_meta.merge(@meta)
          adapter_instance.render_collection(serialized_data, combined_meta, @request.data, render_meta)
        else
          { ok: true }.merge(serialized_data).merge(meta: @meta)
        end
      end

      def resource_response(resource)
        includes_param = @request.data[:include]
        adapter_instance = adapter
        render_meta = render_metadata

        scoped_resource = if schema_class.present?
                            adapter_instance.record_scope(
                              resource,
                              schema_data,
                              @request.data,
                              render_meta
                            )
                          else
                            resource
                          end

        serialized_data = action_definition.serialize_data(scoped_resource, context: @context, includes: includes_param)

        if schema_class
          adapter_instance.render_record(serialized_data, @meta, @request.data, render_meta)
        else
          response = { ok: true }.merge(serialized_data)
          response[:meta] = @meta if @meta.present?
          response
        end
      end

      private

      def adapter
        @adapter ||= @contract_class.api_class.adapter
      end

      def schema_data
        @schema_data ||= Adapter::SchemaData.new(schema_class)
      end

      def render_metadata
        @render_metadata ||= Adapter::RenderMetadata.new(
          action_name: @action,
          http_method: @method,
          schema_data: schema_data,
          contract_class: @contract_class
        )
      end
    end
  end
end
