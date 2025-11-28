# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(data, meta: {}, status: nil)
        schema_class = contract_class.schema_class

        json = if schema_class
                 render_with_schema(data, schema_class, meta)
               else
                 data[:meta] = meta if meta.present?
                 data
               end

        if Rails.env.development?
          result = contract_class.parse_response(body: json, action: action_name)
          result.issues.each(&:warn)
        end

        json = adapter.transform_response(json, schema_class) if schema_class
        render json: json, status: status || (action_name.to_sym == :create ? :created : :ok)
      end

      def render_error(issues, status: :bad_request)
        json = adapter.render_error(issues, build_action_data)
        render json: json, status: status
      end

      private

      def render_with_schema(data, schema_class, meta)
        if data.is_a?(Enumerable)
          adapter.render_collection(data, schema_class, build_action_data(meta))
        else
          validate_record_errors!(data, schema_class)
          adapter.render_record(data, schema_class, build_action_data(meta))
        end
      end

      def validate_record_errors!(record, schema_class)
        return unless record.respond_to?(:errors) && record.errors.any?

        validation_adapter = ValidationAdapter.new(record, schema_class: schema_class)
        raise ValidationError, validation_adapter.convert
      end

      def build_action_data(meta = {})
        Adapter::ActionData.new(
          name: action_name,
          method: request.method_symbol,
          context: context,
          query: contract.query,
          meta: meta
        )
      end

      def context
        {}
      end
    end
  end
end
