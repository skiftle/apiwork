# frozen_string_literal: true

module Apiwork
  module Resource
    # Represents a root key for resource serialization
    #
    # Provides both singular and plural forms of the root key.
    #
    # @example
    #   root_key = RootKey.new("client")
    #   root_key.singular  # => "client"
    #   root_key.plural    # => "clients"
    #
    class RootKey
      def initialize(type)
        @type = type
      end

      # Returns the singular form of the root key
      # Used for: show, create, update, error responses
      #
      # @return [String] singular form (e.g., "client")
      def singular
        @type.singularize
      end

      # Returns the plural form of the root key
      # Used for: index (collection) responses
      #
      # @return [String] plural form (e.g., "clients")
      def plural
        @type.pluralize
      end

      # String representation defaults to singular
      # Allows using root_key in string contexts
      #
      # @return [String] singular form
      def to_s
        singular
      end

      # Inspect for debugging
      def inspect
        "#<Apiwork::Resource::RootKey singular=#{singular.inspect} plural=#{plural.inspect}>"
      end
    end
  end
end
