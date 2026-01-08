# frozen_string_literal: true

module Apiwork
  # @api public
  module Adapter
    class << self
      delegate :all,
               :find,
               :registered?,
               to: Registry

      # @api public
      # Registers an adapter.
      #
      # @param klass [Class] an {Adapter::Base} subclass with adapter_name set
      # @see Adapter::Base
      #
      # @example
      #   Apiwork::Adapter.register(JSONAPIAdapter)
      delegate :register, to: Registry

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
