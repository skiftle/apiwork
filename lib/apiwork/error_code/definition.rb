# frozen_string_literal: true

module Apiwork
  module ErrorCode
    # @api public
    # Represents a registered error code.
    #
    # Error codes define HTTP status codes and behavior for API errors.
    # Retrieved via {ErrorCode.find} or {ErrorCode.find!}.
    #
    # @!attribute [r] key
    #   @api public
    #   @return [Symbol]
    #
    # @!attribute [r] status
    #   @api public
    #   @return [Integer]
    #
    # @example
    #   error_code = Apiwork::ErrorCode.find!(:not_found)
    #   error_code.key     # => :not_found
    #   error_code.status  # => 404
    #   error_code.attach_path? # => true
    Definition = Struct.new(:key, :status, :attach_path, keyword_init: true) do
      # @api public
      # Whether to include request path in error response.
      #
      # @return [Boolean]
      def attach_path?
        attach_path
      end

      # @api public
      # Returns a localized description for the error code.
      #
      # Looks up `apiwork.apis.<locale_key>.error_codes.<key>.description`,
      # falls back to `apiwork.error_codes.<key>.description`,
      # then to titleized key.
      #
      # @param locale_key [String, nil] I18n namespace for API-specific translations
      # @return [String]
      #
      # @example
      #   error_code = Apiwork::ErrorCode.find!(:not_found)
      #   error_code.description # => "Not Found"
      #   error_code.description(locale_key: 'api/v1') # apiwork.apis.api/v1.error_codes.not_found.description
      def description(locale_key: nil)
        if locale_key
          api_key = :"apiwork.apis.#{locale_key}.error_codes.#{key}.description"
          result = I18n.translate(api_key, default: nil)
          return result if result
        end

        global_key = :"apiwork.error_codes.#{key}.description"
        result = I18n.translate(global_key, default: nil)
        return result if result

        key.to_s.titleize
      end
    end
  end
end
