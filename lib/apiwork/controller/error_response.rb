# frozen_string_literal: true

module Apiwork
  module Controller
    module ErrorResponse
      extend ActiveSupport::Concern

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
