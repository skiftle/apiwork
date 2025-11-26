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
        return collection_without_schema(collection) unless schema_class

        adapter.render_collection(collection, schema_class, @request.data, @meta, adapter_context)
      end

      def resource_response(resource)
        return resource_without_schema(resource) unless schema_class

        adapter.render_record(resource, schema_class, @request.data, @meta, adapter_context)
      end

      private

      def collection_without_schema(collection)
        response = { data: collection }
        response[:meta] = @meta if @meta.present?
        response
      end

      def resource_without_schema(resource)
        response = { data: resource }
        response[:meta] = @meta if @meta.present?
        response
      end

      def adapter
        @adapter ||= @contract_class.api_class.adapter
      end

      def adapter_context
        @adapter_context ||= Adapter::Context.new(
          action_name: @action,
          method: @method,
          actions: {}
        )
      end
    end
  end
end
