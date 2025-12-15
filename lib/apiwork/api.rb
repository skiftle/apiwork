# frozen_string_literal: true

module Apiwork
  module API
    class << self
      # Defines a new API at the given path.
      #
      # This is the main entry point for creating an Apiwork API.
      # The block receives an API recorder for defining resources,
      # types, and configuration.
      #
      # @param path [String] the mount path for this API (e.g. '/api/v1')
      # @yield block for API definition
      # @return [Class] the created API class (subclass of API::Base)
      #
      # @example Basic API
      #   Apiwork::API.draw '/api/v1' do
      #     resources :users
      #     resources :posts
      #   end
      #
      # @example With configuration
      #   Apiwork::API.draw '/api/v1' do
      #     key_format :camel
      #
      #     resources :invoices
      #   end
      def draw(path, &block)
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

      # DOCUMENTATION
      def introspect(path, locale: nil)
        find(path)&.introspect(locale:)
      end

      # DOCUMENTATION
      def reset!
        Registry.clear!
      end
    end
  end
end
