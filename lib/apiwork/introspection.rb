# frozen_string_literal: true

module Apiwork
  module Introspection
    class << self
      def api(api_class, locale: nil)
        data = with_locale(locale) { APISerializer.new(api_class).serialize }
        API.new(data)
      end

      def contract(contract_class, expand: false, locale: nil)
        data = with_locale(locale) { ContractSerializer.new(contract_class, expand:).serialize }
        Contract.new(data)
      end

      private

      def with_locale(locale, &block)
        return yield unless locale

        unless I18n.available_locales.include?(locale)
          raise ConfigurationError,
                "locale must be one of #{I18n.available_locales.inspect}, got #{locale.inspect}"
        end

        I18n.with_locale(locale, &block)
      end
    end
  end
end
