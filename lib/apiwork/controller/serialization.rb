# frozen_string_literal: true

module Apiwork
  module Controller
    module Serialization
      extend ActiveSupport::Concern

      included do
        rescue_from Apiwork::ConstraintError do |error|
          render_error error.issues, status: error.error_code.status
        end
      end

      def respond(data, meta: {}, status: nil)
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

      def respond_with_error(code_key, detail: nil, path: nil, meta: {}, i18n: {})
        error_code = ErrorCode.fetch(code_key)

        issue = Issue.new(
          code: error_code.key,
          detail: resolve_error_detail(error_code, detail, i18n),
          path: path || default_error_path(error_code),
          meta:
        )

        render_error [issue], status: error_code.status
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

      def default_error_path(error_code)
        return relative_path.split('/').reject(&:blank?) if error_code.attach_path?

        []
      end

      def resolve_error_detail(error_code, detail, options)
        return detail if detail

        api_path = api_class.metadata&.locale_key
        error_code.description(api_path:, options:)
      end
    end
  end
end
