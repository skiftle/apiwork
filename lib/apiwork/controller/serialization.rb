# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      def render_with_contract(data, meta: {}, status: nil)
        action_def = contract_class.action_definitions[action_name.to_sym]

        if action_def&.response_definition&.no_content?
          head :no_content
          return
        end

        schema_class = contract_class.schema_class

        json = if schema_class
                 render_with_schema(data, schema_class, meta)
               else
                 data[:meta] = meta if meta.present?
                 data
               end

        if Rails.env.development?
          result = contract_class.parse_response(json, action_name)
          result.issues.each(&:warn)
        end

        json = adapter.transform_response(json)
        json = api_class.transform_response(json)
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
          adapter.render_record(data, schema_class, build_action_data(meta))
        end
      end

      def build_action_data(meta = {})
        Adapter::ActionData.new(
          action_name,
          request.method_symbol,
          context:,
          query: resource_metadata ? contract.query : {},
          meta:
        )
      end

      def context
        {}
      end
    end
  end
end
