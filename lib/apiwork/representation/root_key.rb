# frozen_string_literal: true

module Apiwork
  module Representation
    # @api public
    # Represents the JSON root key for a representation.
    #
    # Root keys wrap response data in a named container.
    # Used by adapters to structure JSON responses.
    #
    # @example
    #   root_key = InvoiceRepresentation.root_key
    #   root_key.singular # => "invoice"
    #   root_key.plural # => "invoices"
    class RootKey
      # @!attribute [r] plural
      #   @api public
      #   The plural root key.
      #
      #   @return [String]
      # @!attribute [r] singular
      #   @api public
      #   The singular root key.
      #
      #   @return [String]
      attr_reader :plural,
                  :singular

      def initialize(singular, plural = singular.pluralize)
        @singular = singular
        @plural   = plural
      end
    end
  end
end
