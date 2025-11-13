# frozen_string_literal: true

module Apiwork
  module Schema
    class RootKey
      def initialize(singular, plural = nil)
        @singular = singular
        @plural = plural || singular&.pluralize
      end

      attr_reader :singular

      attr_reader :plural

      def to_s
        singular
      end

      # Inspect for debugging
      def inspect
        "#<Apiwork::Schema::RootKey singular=#{singular.inspect} plural=#{plural.inspect}>"
      end
    end
  end
end
