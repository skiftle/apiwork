# frozen_string_literal: true

module Apiwork
  module Controller
    module ErrorResponse
      extend ActiveSupport::Concern

      def respond_with_error(code_key, detail: nil, path: [], meta: {}, i18n: {})
        error_code = ErrorCode.fetch(code_key)

        issue = Issue.new(
          code: error_code.key,
          detail: resolve_error_detail(error_code.key, detail, i18n),
          path:,
          meta:
        )

        render_error [issue], status: error_code.status
      end

      private

      def resolve_error_detail(code_key, detail, i18n_options)
        return detail if detail

        if api_class.metadata.path
          api_path = api_class.metadata.path.delete_prefix('/')
          api_key = :"apiwork.apis.#{api_path}.error_codes.#{code_key}"
          translation = I18n.t(api_key, **i18n_options, default: nil)
          return translation if translation
        end

        global_key = :"apiwork.error_codes.#{code_key}"
        translation = I18n.t(global_key, **i18n_options, default: nil)
        return translation if translation

        code_key.to_s.titleize
      end
    end
  end
end
