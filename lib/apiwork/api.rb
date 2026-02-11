# frozen_string_literal: true

module Apiwork
  # @api public
  # Namespace for API definitions and the API registry.
  module API
    class << self
      # @!method find(path)
      #   @api public
      #   Finds an API by path.
      #   @param path [String]
      #     The API path.
      #   @return [Class<API::Base>, nil]
      #   @see .find!
      #   @example
      #     Apiwork::API.find('/api/v1')
      #
      # @!method find!(path)
      #   @api public
      #   Finds an API by path.
      #   @param path [String]
      #     The API path.
      #   @return [Class<API::Base>]
      #   @raise [KeyError] if the API is not found
      #   @see .find
      #   @example
      #     Apiwork::API.find!('/api/v1')
      delegate :clear!,
               :exists?,
               :find,
               :find!,
               :keys,
               :unregister,
               :values,
               to: Registry

      # @api public
      # Defines a new API at the given path.
      #
      # This is the main entry point for creating an Apiwork API.
      # The block receives an API recorder for defining resources,
      # types, and configuration.
      #
      # @param path [String]
      #   The API path.
      # @yield block for API definition
      # @return [Class<API::Base>]
      #
      # @example Basic API
      #   Apiwork::API.define '/api/v1' do
      #     resources :users
      #     resources :posts
      #   end
      #
      # @example With configuration
      #   Apiwork::API.define '/api/v1' do
      #     key_format :camel
      #
      #     resources :invoices
      #   end
      def define(path, &block)
        return unless block

        Class.new(Base).tap do |klass|
          klass.mount(path)
          klass.class_eval(&block)
        end
      end

      # @api public
      # The introspection data for an API.
      #
      # @param path [String]
      #   The API path.
      # @param locale [Symbol, nil] (nil)
      #   The locale for descriptions.
      # @return [Introspection::API]
      #
      # @example
      #   Apiwork::API.introspect('/api/v1')
      def introspect(path, locale: nil)
        find!(path).introspect(locale:)
      end
    end
  end
end
