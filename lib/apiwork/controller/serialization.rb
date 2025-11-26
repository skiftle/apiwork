# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(resource_or_collection, meta: {}, status: nil)
        action_definition = current_contract.action_definition(action_name)
        schema_class = action_definition&.schema_class
        meta = current_contract.format_keys(meta, :response)

        response = if resource_or_collection.is_a?(Enumerable)
                     render_collection_response(resource_or_collection, schema_class, meta)
                   else
                     render_record_response(resource_or_collection, schema_class, meta)
                   end

        skip_validation = request.delete? && schema_class.present?
        unless skip_validation
          result = current_contract.parse(response, :response_body, action_name, coerce: false, context: context)
          raise ContractError, result.issues if result.invalid?
        end

        render json: response, status: status || (action_name.to_sym == :create ? :created : :ok)
      end

      def render_error(issues, status: :bad_request)
        issues_array = Array(issues)
        response = adapter.render_error(issues_array, action_data)
        render json: response, status: status
      end

      private

      def render_collection_response(collection, schema_class, meta)
        return collection_without_schema(collection, meta) unless schema_class

        adapter.render_collection(collection, schema_class, action_data(meta))
      end

      def render_record_response(record, schema_class, meta)
        if record.respond_to?(:errors) && record.errors.any?
          validation_adapter = ValidationAdapter.new(record, schema_class: schema_class)
          raise ValidationError, validation_adapter.convert
        end

        return record_without_schema(record, meta) unless schema_class

        adapter.render_record(record, schema_class, action_data(meta))
      end

      def collection_without_schema(collection, meta)
        response = { data: collection }
        response[:meta] = meta if meta.present?
        response
      end

      def record_without_schema(record, meta)
        response = { data: record }
        response[:meta] = meta if meta.present?
        response
      end

      def adapter
        @adapter ||= current_contract.api_class.adapter
      end

      def action_data(meta = {})
        Adapter::ActionData.new(
          name: action_name,
          method: request.method_symbol,
          context: context,
          query: action_request.data,
          meta: meta
        )
      end

      def context
        {}
      end
    end
  end
end
