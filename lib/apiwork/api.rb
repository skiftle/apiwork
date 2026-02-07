# frozen_string_literal: true

module Apiwork
  # @api public
  module API
    class << self
      # @!method find(path)
      #   @api public
      #   Finds an API by its mount path.
      #   @param path [String] the API mount path
      #   @return [Class<API::Base>, nil] the API class
      #   @see .find!
      #   @example
      #     Apiwork::API.find('/api/v1')
      #
      # @!method find!(path)
      #   @api public
      #   Finds an API by its mount path.
      #   @param path [String] the API mount path
      #   @return [Class<API::Base>] the API class
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
      # @param path [String] the mount path for this API (e.g. '/api/v1')
      # @yield block for API definition
      # @return [API::Base]
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
      # Returns introspection data for an API.
      #
      # @param path [String] the API mount path
      # @param locale [Symbol] optional locale for descriptions
      # @return [Hash] the introspection data
      #
      # @example
      #   Apiwork::API.introspect('/api/v1')
      def introspect(path, locale: nil)
        find!(path).introspect(locale:)
      end
    end
  end
end
