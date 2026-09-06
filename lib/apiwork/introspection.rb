# frozen_string_literal: true

module Apiwork
  module Introspection
    class << self
      def api(api_class, locale: nil)
        validate_locale(api_class, locale)
        with_locale(locale) { API.new(Dump.api(api_class)) }
      end

      def contract(contract_class, expand: false, locale: nil)
        validate_locale(contract_class.api_class, locale)
        with_locale(locale) { Contract.new(Dump.contract(contract_class, expand:)) }
      end

      private

      def validate_locale(api_class, locale)
        return unless locale
        return unless api_class

        if api_class.locales.empty?
          raise ConfigurationError,
                "locale :#{locale} was requested but no locales are defined. " \
                "Add `locales #{locale.inspect}` to your API definition."
        end

        return if api_class.locales.include?(locale)

        raise ConfigurationError,
              "locale must be one of #{api_class.locales.inspect}, got #{locale.inspect}"
      end

      def with_locale(locale, &block)
        return yield unless locale

        I18n.with_locale(locale, &block)
      end
    end
  end
end
