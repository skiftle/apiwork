# frozen_string_literal: true

module Apiwork
  # @api public
  module Adapter
    class << self
      # @api public
      # Registers an adapter.
      #
      # @param klass [Class] an {Adapter::Base} subclass with adapter_name set
      # @see Adapter::Base
      #
      # @example
      #   Apiwork::Adapter.register(JSONAPIAdapter)
      def register(klass)
        Registry.register(klass)
      end

      def find(adapter_name)
        Registry.find(adapter_name)
      end

      def registered?(adapter_name)
        Registry.registered?(adapter_name)
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
