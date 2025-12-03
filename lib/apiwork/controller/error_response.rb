# frozen_string_literal: true

module Apiwork
  module Controller
    module ErrorResponse
      extend ActiveSupport::Concern

      def respond_with_error(code, detail: nil, path: [], meta: {}, i18n: {})
        definition = ErrorCode.fetch(code)
        resolved_detail = resolve_error_detail(code, detail, i18n)

        issue = Issue.new(
          code:,
          detail: resolved_detail,
          path: Array(path),
          meta:
        )

        render_error [issue], status: definition.status
      end

      private

      def resolve_error_detail(code, detail, i18n_options)
        return detail if detail

        if api_class.metadata.path
          api_path = api_class.metadata.path.delete_prefix('/')
          api_key = :"apiwork.apis.#{api_path}.error_codes.#{code}"
          translation = I18n.t(api_key, **i18n_options, default: nil)
          return translation if translation
        end

        global_key = :"apiwork.error_codes.#{code}"
        translation = I18n.t(global_key, **i18n_options, default: nil)
        return translation if translation

        code.to_s.titleize
      end
    end
  end
end
