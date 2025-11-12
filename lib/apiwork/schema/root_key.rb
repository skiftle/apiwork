# frozen_string_literal: true

module Apiwork
  module Schema
    # Represents a root key for resource serialization
    #
    # Provides both singular and plural forms of the root key.
    #
    # @example Auto-pluralization
    #   root_key = RootKey.new("client")
    #   root_key.singular  # => "client"
    #   root_key.plural    # => "clients"
    #
    # @example Explicit plural
    #   root_key = RootKey.new("person", "people")
    #   root_key.singular  # => "person"
    #   root_key.plural    # => "people"
    #
    class RootKey
      def initialize(singular, plural = nil)
        @singular = singular
        @plural = plural || singular&.pluralize
      end

      # Returns the singular form of the root key
      # Used for: show, create, update, error responses
      #
      # @return [String] singular form (e.g., "client")
      attr_reader :singular

      # Returns the plural form of the root key
      # Used for: index (collection) responses
      #
      # @return [String] plural form (e.g., "clients")
      attr_reader :plural

      # String representation defaults to singular
      # Allows using root_key in string contexts
      #
      # @return [String] singular form
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
