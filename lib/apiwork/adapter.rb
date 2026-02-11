# frozen_string_literal: true

module Apiwork
  # @api public
  # Namespace for adapters and the adapter registry.
  module Adapter
    class << self
      # @!method find(name)
      #   @api public
      #   Finds an adapter by name.
      #   @param name [Symbol]
      #     The adapter name.
      #   @return [Class<Adapter::Base>, nil]
      #   @see .find!
      #   @example
      #     Apiwork::Adapter.find(:standard)
      #
      # @!method find!(name)
      #   @api public
      #   Finds an adapter by name.
      #   @param name [Symbol]
      #     The adapter name.
      #   @return [Class<Adapter::Base>]
      #   @raise [KeyError] if the adapter is not found
      #   @see .find
      #   @example
      #     Apiwork::Adapter.find!(:standard)
      #
      # @!method register(klass)
      #   @api public
      #   Registers an adapter.
      #   @param klass [Class<Adapter::Base>]
      #     The adapter class with adapter_name set.
      #   @see Adapter::Base
      #   @example
      #     Apiwork::Adapter.register(JSONAPIAdapter)
      delegate :clear!,
               :exists?,
               :find,
               :find!,
               :keys,
               :register,
               :values,
               to: Registry

      def register_defaults!
        register(Standard)
      end
    end
  end
end
