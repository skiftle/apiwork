# frozen_string_literal: true

module Apiwork
  module Introspection
    class << self
      def api(api_class, locale: nil)
        with_locale(locale) { ApiSerializer.new(api_class).serialize }
      end

      def contract(contract_class, action: nil, locale: nil)
        with_locale(locale) { ContractSerializer.new(contract_class, action:).serialize }
      end

      def action_definition(action_definition, locale: nil)
        with_locale(locale) { ActionSerializer.new(action_definition).serialize }
      end

      def types(api_class, locale: nil)
        with_locale(locale) { TypeSerializer.new(api_class).serialize_types }
      end

      def enums(api_class, locale: nil)
        with_locale(locale) { TypeSerializer.new(api_class).serialize_enums }
      end

      def definition(definition, locale: nil)
        with_locale(locale) { DefinitionSerializer.new(definition).serialize }
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
