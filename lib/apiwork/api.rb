# frozen_string_literal: true

module Apiwork
  # @api public
  # Entry point for defining APIs.
  #
  # Use {.define} to create an API with resources, types, and configuration.
  module API
    class << self
      # @api public
      # Defines a new API at the given path.
      #
      # This is the main entry point for creating an Apiwork API.
      # The block receives an API recorder for defining resources,
      # types, and configuration.
      #
      # @param path [String] the mount path for this API (e.g. '/api/v1')
      # @yield block for API definition
      # @return [Class] an {API::Base} subclass
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

      def find(path)
        Registry.find(path)
      end

      def all
        Registry.all
      end

      def unregister(path)
        Registry.unregister(path)
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
        find(path)&.introspect(locale:)
      end

      # @api public
      # Clears all registered APIs. Intended for test cleanup.
      #
      # @example
      #   Apiwork::API.reset!
      def reset!
        Registry.clear!
      end
    end
  end
end
