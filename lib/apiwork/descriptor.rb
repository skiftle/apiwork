# frozen_string_literal: true

module Apiwork
  module Descriptor
    class << self
      delegate :register_type, :register_enum, :register_union,
               :resolve_type, :resolve_enum,
               to: Registry

      delegate :define_type, :define_enum, :define_union,
               to: Builder

      def reset!
        Registry.clear!
      end

      def scoped_type_name(scope, name)
        Registry.scoped_name(scope, name)
      end

      def scoped_enum_name(scope, name)
        EnumStore.scoped_name(scope, name)
      end
    end
  end
end
