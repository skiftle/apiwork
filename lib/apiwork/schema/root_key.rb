# frozen_string_literal: true

module Apiwork
  module Schema
    # @api public
    # Represents the JSON root key for a schema.
    #
    # Root keys wrap response data in a named container.
    # Used by adapters to structure JSON responses.
    #
    # @example
    #   root_key = InvoiceSchema.root_key
    #   root_key.singular  # => "invoice"
    #   root_key.plural    # => "invoices"
    class RootKey
      # @api public
      # @return [String] root key for collections
      attr_reader :plural

      # @api public
      # @return [String] root key for single records
      attr_reader :singular

      def initialize(singular, plural = singular.pluralize)
        @singular = singular
        @plural   = plural
      end

      # @api public
      # Returns the singular root key.
      #
      # @return [String]
      def to_s
        singular
      end
    end
  end
end
