# frozen_string_literal: true

module Apiwork
  # @api public
  module Adapter
    class << self
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
               :register,
               :registered?,
               to: Registry

      def register_defaults!
        register(Standard)
      end
    end
  end
end
