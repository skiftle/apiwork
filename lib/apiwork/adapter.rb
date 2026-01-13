# frozen_string_literal: true

module Apiwork
  # @api public
  module Adapter
    class << self
      # @!method find(name)
      #   @api public
      #   Finds an adapter by name.
      #   @param name [Symbol] the adapter name
      #   @return [Adapter::Base, nil] the adapter class or nil if not found
      #   @see .find!
      #   @example
      #     Apiwork::Adapter.find(:standard)
      #
      # @!method find!(name)
      #   @api public
      #   Finds an adapter by name.
      #   @param name [Symbol] the adapter name
      #   @return [Adapter::Base] the adapter class
      #   @raise [KeyError] if the adapter is not found
      #   @see .find
      #   @example
      #     Apiwork::Adapter.find!(:standard)
      #
      # @!method register(klass)
      #   @api public
      #   Registers an adapter.
      #   @param klass [Class] an {Adapter::Base} subclass with adapter_name set
      #   @see Adapter::Base
      #   @example
      #     Apiwork::Adapter.register(JSONAPIAdapter)
      delegate :all,
               :clear!,
               :find,
               :find!,
               :register,
               :registered?,
               to: Registry

      def register_defaults!
        register(Standard)
      end
    end
  end
end
