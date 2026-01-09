# frozen_string_literal: true

module Apiwork
  module ErrorCode
    Definition = Struct.new(:key, :status, :attach_path, keyword_init: true) do
      def attach_path?
        attach_path
      end

      def to_h(locale_key: nil)
        {
          description: description(locale_key:),
          status: status,
        }
      end

      def description(locale_key: nil, options: {})
        if locale_key
          api_key = :"apiwork.apis.#{locale_key}.error_codes.#{key}.description"
          result = I18n.t(api_key, **options, default: nil)
          return result if result
        end

        global_key = :"apiwork.error_codes.#{key}.description"
        result = I18n.t(global_key, **options, default: nil)
        return result if result

        key.to_s.titleize
      end
    end
  end
end
