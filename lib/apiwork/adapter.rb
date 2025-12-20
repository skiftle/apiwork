# frozen_string_literal: true

module Apiwork
  # @api public
  module Adapter
    class << self
      # @api public
      # Registers an adapter.
      #
      # @param klass [Class] the adapter class (subclass of Adapter::Base with identifier)
      #
      # @example
      #   Apiwork::Adapter.register(JsonApiAdapter)
      def register(klass)
        Registry.register(klass)
      end

      def find(identifier)
        Registry.find(identifier)
      end

      def registered?(identifier)
        Registry.registered?(identifier)
      end

      def all
        Registry.all
      end

      # @api public
      # Clears all registered adapters. Intended for test cleanup.
      #
      # @example
      #   Apiwork::Adapter.reset!
      def reset!
        Registry.clear!
      end
    end
  end
end
