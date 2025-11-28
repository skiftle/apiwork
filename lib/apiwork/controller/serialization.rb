# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def respond_with(data, meta: {}, status: nil)
        schema_class = contract_class.schema_class

        response = if schema_class
                     render_with_schema(data, schema_class, meta)
                   else
                     add_meta(data, meta)
                   end

        if Rails.env.development?
          result = contract_class.parse_response(body: response, action: action_name)
          result.issues.each(&:warn)
        end

        response = adapter.transform_response(response, schema_class) if schema_class

        render json: response, status: status || (action_name.to_sym == :create ? :created : :ok)
      end

      def render_error(issues, status: :bad_request)
        issues_array = Array(issues)
        response = adapter.render_error(issues_array, action_data)
        render json: response, status: status
      end

      private

      def add_meta(data, meta)
        data[:meta] = meta if meta.present?
        data
      end

      def render_with_schema(data, schema_class, meta)
        if data.is_a?(Enumerable)
          adapter.render_collection(data, schema_class, action_data(meta))
        else
          validate_record_errors!(data, schema_class)
          adapter.render_record(data, schema_class, action_data(meta))
        end
      end

      def validate_record_errors!(record, schema_class)
        return unless record.respond_to?(:errors) && record.errors.any?

        validation_adapter = ValidationAdapter.new(record, schema_class: schema_class)
        raise ValidationError, validation_adapter.convert
      end

      def action_data(meta = {})
        Adapter::ActionData.new(
          name: action_name,
          method: request.method_symbol,
          context: context,
          query: (contract.query || {}).merge(contract.body || {}),
          meta: meta
        )
      end

      def context
        {}
      end
    end
  end
end
