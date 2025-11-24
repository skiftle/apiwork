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
        context = adapter_context

        load_result = if schema_class.present?
                        adapter_instance.load_collection(
                          collection,
                          schema_class,
                          @request.data,
                          context
                        )
                      else
                        Adapter::LoadResult.new(collection)
                      end

        serialized_data = action_definition.serialize_data(load_result.data,
                                                           context: @context,
                                                           includes: includes_param)

        serialized_scope_result = Adapter::LoadResult.new(serialized_data, load_result.metadata)

        if schema_class
          adapter_instance.render_collection(serialized_scope_result, @meta, @request.data, schema_class, context)
        else
          serialized_data.merge(meta: @meta)
        end
      end

      def resource_response(resource)
        includes_param = @request.data[:include]
        adapter_instance = adapter
        context = adapter_context

        load_result = if schema_class.present?
                        adapter_instance.load_record(
                          resource,
                          schema_class,
                          @request.data,
                          context
                        )
                      else
                        Adapter::LoadResult.new(resource)
                      end

        serialized_data = action_definition.serialize_data(load_result.data, context: @context, includes: includes_param)

        serialized_scope_result = Adapter::LoadResult.new(serialized_data, load_result.metadata)

        if schema_class
          adapter_instance.render_record(serialized_scope_result, @meta, @request.data, schema_class, context)
        else
          response = serialized_data
          response[:meta] = @meta if @meta.present?
          response
        end
      end

      private

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
