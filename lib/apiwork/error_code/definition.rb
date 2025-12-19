# frozen_string_literal: true

module Apiwork
  module ErrorCode
    # @api private
    Definition = Struct.new(:key, :status, :attach_path, keyword_init: true) do
      def attach_path?
        attach_path
      end

      def description(api_path: nil, options: {})
        if api_path
          api_key = :"apiwork.apis.#{api_path}.error_codes.#{key}.description"
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
